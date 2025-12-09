from typing import Annotated
import os
import re
import orjson

from langchain_core.language_models import BaseChatModel
from langchain_core.messages import BaseMessage, SystemMessage, AIMessage
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph, START
from langgraph.graph.message import add_messages
from typing_extensions import TypedDict
from langchain_ollama import ChatOllama
from dotenv import load_dotenv
from tools import search_web

# загрузка .env
load_dotenv()

MAIN_PROMPT = """
Твоя цель — помочь пользователю подобрать подарок, следуя этим правилам:

Если ты ещё плохо представляешь получателя — задай 2–3 вопроса (возраст, пол, интересы, повод, бюджет).
Когда информации достаточно — предложи 3–4 конкретных идеи подарков.
Не абстрактные категории, а реальные вещи или услуги. Пиши как человек, который советует другу.
Не делай длинных уточнений, не пиши ответы в скобках.
Каждый ответ должен быть нормальным текстом и заканчиваться вопросом,
кроме случая, когда ты уже добавляешь [READY_TO_SEARCH].
Общайся дружелюбно и естественно, без лишней воды.
Когда предлагаешь идеи подарков:

ВСЕГДА давай их пронумерованным списком:
1) ...
2) ...
3) ...
В конце задавай вопрос: «Какой номер тебе нравится больше всего?»
Когда пользователь выбирает вариант (пишет номер или «первый / второй / третий» и т.п.):

Не предлагай новые идеи, не задавай лишних вопросов.
Ответь коротко, в таком формате:
«Отлично, тогда берём вариант №2.
Выбранный подарок: Набор бильярдных шаров для домашнего стола

[READY_TO_SEARCH]»

Важно:

Строчка «Выбранный подарок: ...» должна быть ОДНОЗНАЧНОЙ и содержать то, что нужно искать в магазине.
Маркер [READY_TO_SEARCH] должен быть в конце сообщения, отдельной строкой или последним токеном.
После перехода в поиск возьми выбранный подарок как поисковый запрос, показывай по каждой ссылке
название, цену, рейтинг и число отзывов (рейтинг на маркетплейсах обычно рядом со звёздочкой и отзывами),
сортируй найденные товары по убыванию числа отзывов.
"""


class State(TypedDict):
    messages: Annotated[list[BaseMessage], add_messages]


def _prepend_system(prompt: str, messages: list[BaseMessage]) -> list[BaseMessage]:
    return [SystemMessage(content=prompt)] + messages


def _parse_number(raw: str | None) -> float:
    if not raw:
        return -1.0
    cleaned = raw.replace(" ", "").replace("\xa0", "").strip()
    cleaned = cleaned.replace(",", ".")
    try:
        return float(cleaned)
    except Exception:
        return -1.0


def create_gift_agent(model_name: str | None = None):
    llm_plain: BaseChatModel = ChatOllama(
        model=model_name or os.getenv("MODEL_NAME"),
        temperature=0.3,
    )

    # ---------- NODE 1: диалог ----------
    async def gift_dialog(state: State):
        messages = state["messages"]
        resp = await llm_plain.ainvoke(_prepend_system(MAIN_PROMPT, messages))
        return {"messages": [resp]}

    # ---------- NODE 2: поиск на Маркете ----------
    async def search_products(state: State):
        messages = state["messages"]

        # ищем последний AI с [READY_TO_SEARCH]
        last_ai = None
        for m in reversed(messages):
            if isinstance(m, AIMessage) and "[READY_TO_SEARCH]" in m.content:
                last_ai = m
                break

        if last_ai is None:
            # fallback: берём последний ввод пользователя
            last_user_text = ""
            for m in reversed(messages):
                if getattr(m, "type", "") == "human":
                    last_user_text = m.content.strip()
                    break
            chosen = last_user_text or "подарки"
        else:
            # парсим строку вида «Выбранный подарок: ...»
            chosen = "подарки"
            for line in last_ai.content.splitlines():
                line = line.strip()
                if line.lower().startswith("выбранный подарок:"):
                    chosen = line.split(":", 1)[1].strip()
                    break

        search_query = f"подарок {chosen}".strip()

        # вызываем инструмент поиска (он уже парсит Маркет и отдаёт JSON)
        raw = await search_web.ainvoke({"query": search_query, "num_results": 5})

        products: list[dict] = []

        try:
            data = orjson.loads(raw)
        except Exception:
            data = None

        if isinstance(data, list):
            for item in data:
                if not isinstance(item, dict):
                    continue
                products.append(
                    {
                        "title": item.get("title") or "",
                        "price": item.get("price"),
                        "rating": item.get("rating"),
                        "purchases": item.get("purchases"),
                        # если ссылки нет или None → пустая строка
                        "url": item.get("url") or "",
                    }
                )
        else:
            products = []

        # всегда возвращаем JSON-массив товаров
        json_str = orjson.dumps(products, option=orjson.OPT_INDENT_2).decode()
        return {"messages": [AIMessage(content=json_str)]}



    # ---------- ROUTING ----------
    def route_from_dialog(state: State) -> str:
        last = state["messages"][-1]
        if isinstance(last, AIMessage) and "[READY_TO_SEARCH]" in last.content:
            return "search_products"
        return "__end__"

    # ---------- GRAPH ----------
    graph = StateGraph(State)
    graph.add_node("gift_dialog", gift_dialog)
    graph.add_node("search_products", search_products)
    graph.add_edge(START, "gift_dialog")
    graph.add_conditional_edges("gift_dialog", route_from_dialog)

    checkpointer = MemorySaver()
    app = graph.compile(checkpointer=checkpointer)
    return app
