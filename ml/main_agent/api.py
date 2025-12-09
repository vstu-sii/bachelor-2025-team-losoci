# api.py
import os
import orjson

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel,ConfigDict
from dotenv import load_dotenv

from gift_agent import create_gift_agent
from langchain_core.messages import HumanMessage
#from langfuse.langchain import CallbackHandler
#from langfuse import Langfuse

load_dotenv()

"""langfuse = Langfuse(
    public_key=os.getenv("LANGFUSE_PK"),
    secret_key=os.getenv("LANGFUSE_SK"),
    host=os.getenv("LANGFUSE_HOST"),
)"""

#langfuse_handler = CallbackHandler(langfuse=langfuse)

app = FastAPI(title="Gift Agent API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

agent = create_gift_agent(model_name=os.getenv("MODEL_NAME"))


class ChatRequest(BaseModel):
    message: str
    sender_id: str
    recipient_id: str
    model_config = ConfigDict(coerce_numbers_to_str=True)

class Gift(BaseModel):
    title: str | None = None
    price: str | None = None
    rating: str | None = None
    purchases: int | None = None
    url: str = ""  # если ссылки нет — пустая строка


class ChatResponse(BaseModel):
    response: str | None = None
    gifts: list[Gift] | None = None


@app.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    thread_id = req.sender_id + req.recipient_id

    result = await agent.ainvoke(
        {"messages": [HumanMessage(content=req.message)]},
        config={
            "configurable": {"thread_id": thread_id},
            #"callbacks": [langfuse_handler],
            "metadata": {
                "thread_id": thread_id,
                "sender_id": req.sender_id,
                "recipient_id": req.recipient_id,
            },  
        },
    )

    messages = result["messages"]
    ai_messages = [m for m in messages if getattr(m, "type", "") == "ai"]

    response_text: str | None = None
    gifts: list[Gift] | None = None

    # ищем последний AI с JSON-массивом (результат search_products)
    json_list = None
    json_ai_index: int | None = None

    for i in range(len(ai_messages) - 1, -1, -1):
        m = ai_messages[i]
        raw = m.content
        if not isinstance(raw, str):
            continue
        try:
            parsed = orjson.loads(raw)
        except Exception:
            continue
        if isinstance(parsed, list):
            json_list = parsed
            json_ai_index = i
            break

    if json_list is not None:
        gifts = []
        for item in json_list:
            if not isinstance(item, dict):
                continue
            gifts.append(
                Gift(
                    title=item.get("title"),
                    price=item.get("price"),
                    rating=item.get("rating"),
                    purchases=item.get("purchases"),
                    url=item.get("url") or "",
                )
            )

        # текстовый ответ — предыдущий AI до JSON
        response_text = ""
        if json_ai_index is not None:
            for m in reversed(ai_messages[:json_ai_index]):
                raw = m.content
                if not isinstance(raw, str):
                    continue
                try:
                    parsed = orjson.loads(raw)
                    if isinstance(parsed, list):
                        continue
                except Exception:
                    pass
                response_text = raw
                break
    else:
        # обычный диалог без поиска
        if ai_messages:
            response_text = str(ai_messages[-1].content)
        else:
            response_text = ""
        gifts = None

    return ChatResponse(response=response_text, gifts=gifts)

