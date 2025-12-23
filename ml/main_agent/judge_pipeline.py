import json
import os
import sys
from dataclasses import dataclass
from typing import List
from pathlib import Path

from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

DEFAULT_MODEL = os.getenv('OPENROUTER_MODEL')


@dataclass
class JudgeInput:
    user_context: str
    gift_answer: str


@dataclass
class JudgeScores:
    relevance_to_recipient: int
    fit_for_occasion: int
    budget_fit: int
    specificity_practicality: int
    diversity_originality: int
    explanation_quality: int
    overall_comment: str
    improvement_suggestions: List[str]


def build_judge_prompt(judge_input: JudgeInput) -> str:
    return f"""
Ты — LLM-судья, оценивающий качество подбора подарков.

Даны: контекст пользователя (получатель, интересы, повод, бюджет и т.п.) и ответ gift-ассистента.
Оцени качество предложенных подарков по шкале 1–5 для каждого критерия. Описание уровней оценки:

1) relevance_to_recipient — насколько подарки подходят возрасту, интересам и профилю получателя.
Оценка 1: подарки никак не связаны с профилем, могут быть неуместными. 
Оценка 2: слабое соответствие, большинство идей не подходят. 
Оценка 3: частичное соответствие, некоторые идеи подходят, но в целом связь слабая. 
Оценка 4: хорошие идеи, большинство подарков уместны и логично связаны с профилем. 
Оценка 5: абсолютное попадание, все идеи точно персонализированы.

2) fit_for_occasion — соответствие повода (Новый год, День рождения, годовщина, подарок коллеге и т.п.).
Оценка 1: подарки полностью не подходят к событию. 
Оценка 2: в целом неуместные идеи, дух повода не учтён. 
Оценка 3: частично подходит, но без учёта особенностей события. 
Оценка 4: хорошие идеи, соответствуют тону и формату события. 
Оценка 5: идеально подходят к случаю, создают верное настроение.

3) budget_fit — реалистичность идей в рамках указанного бюджета.
Оценка 1: подарки сильно выходят за рамки бюджета или слишком дешёвые. 
Оценка 2: часть идей не соответствует бюджету или выглядит несолидно. 
Оценка 3: большинство идей в допустимых рамках, но есть сомнительные. 
Оценка 4: почти все предложения хорошо соответствуют бюджету. 
Оценка 5: идеальное соответствие бюджету, ни один подарок не выходит за рамки.

4) specificity_practicality — конкретность и реализуемость подарков.
Оценка 1: только абстрактные категории («что-нибудь», «что-то интересное»). 
Оценка 2: мало конкретики, непонятно, как реализовать. 
Оценка 3: идеи частично конкретные, но недостаточно детализированы. 
Оценка 4: конкретные, практичные подарки, реалистичные к покупке. 
Оценка 5: высоко детализированные, чёткие и легко реализуемые предложения.

5) diversity_originality — разнообразие и оригинальность.
Оценка 1: идеи однотипные или повторяются. 
Оценка 2: мало вариантов, слабая креативность. 
Оценка 3: есть разнообразие, но умеренное, могут быть повторы. 
Оценка 4: хорошие разнообразные идеи с элементами оригинальности. 
Оценка 5: максимальная креативность и разнообразие, без повторов.

6) explanation_quality — качество объяснений, почему подарок подходит.
Оценка 1: объяснений нет или они бессмысленны. 
Оценка 2: слабые, шаблонные объяснения. 
Оценка 3: объяснения есть, но поверхностные. 
Оценка 4: хорошие, логичные объяснения, привязанные к контексту. 
Оценка 5: глубокие, персонализированные объяснения, чёткая связь с профилем получателя.

Верни строго один JSON без текста до/после, формат:
{{
  "scores": {{
    "relevance_to_recipient": 1,
    "fit_for_occasion": 1,
    "budget_fit": 1,
    "specificity_practicality": 1,
    "diversity_originality": 1,
    "explanation_quality": 1
  }},
  "overall_comment": "строка",
  "improvement_suggestions": [
    "строка 1",
    "строка 2"
  ]
}}
Не добавляй комментарии или пояснения вокруг JSON, только сам объект.

Контекст пользователя:
{judge_input.user_context}

Ответ gift-ассистента:
{judge_input.gift_answer}
""".strip()


def _require_api_key() -> str:
    key = os.getenv("OPENROUTER_API_KEY")
    if not key:
        raise RuntimeError("OPENROUTER_API_KEY is not set in environment.")
    return key


def _make_client() -> OpenAI:
    key = _require_api_key()
    referer = os.getenv("OPENROUTER_SITE_URL")
    site_name = os.getenv("OPENROUTER_SITE_NAME")
    default_headers = {}
    if referer:
        default_headers["HTTP-Referer"] = referer
    if site_name:
        default_headers["X-Title"] = site_name
    return OpenAI(
        base_url="https://openrouter.ai/api/v1",
        api_key=key,
        default_headers=default_headers or None,
    )


def call_llm_judge(
    judge_input: JudgeInput,
    model: str = DEFAULT_MODEL,
) -> JudgeScores:
    client = _make_client()

    system_prompt = (
        "You are an impartial judge for gift recommendations. "
        "Score strictly by the provided rubric and return only the requested JSON."
    )

    try:
        response = client.chat.completions.create(
            model=os.getenv('OPENROUTER_MODEL'),
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": build_judge_prompt(judge_input)},
            ],
            temperature=0.2,
        )
    except Exception as e:
        raise RuntimeError(f"LLM call failed: {e}") from e

    if not response.choices:
        raise RuntimeError("No choices returned from LLM judge.")

    content = response.choices[0].message.content
    if not content:
        raise RuntimeError("Empty response content from LLM judge.")

    try:
        parsed = json.loads(content)
    except Exception as e:
        raise ValueError(f"Failed to parse LLM response as JSON: {e}\nRaw content: {content}") from e

    try:
        scores = parsed["scores"]
        return JudgeScores(
            relevance_to_recipient=int(scores["relevance_to_recipient"]),
            fit_for_occasion=int(scores["fit_for_occasion"]),
            budget_fit=int(scores["budget_fit"]),
            specificity_practicality=int(scores["specificity_practicality"]),
            diversity_originality=int(scores["diversity_originality"]),
            explanation_quality=int(scores["explanation_quality"]),
            overall_comment=str(parsed["overall_comment"]),
            improvement_suggestions=[str(x) for x in parsed.get("improvement_suggestions", [])],
        )
    except Exception as e:
        raise ValueError(f"Unexpected JSON schema from LLM: {e}\nParsed: {parsed}") from e


def evaluate_gift_answer(
    user_context: str,
    gift_answer: str,
    model: str = DEFAULT_MODEL,
) -> JudgeScores:
    return call_llm_judge(JudgeInput(user_context=user_context, gift_answer=gift_answer), model=model)


def _load_log_entry(log_id: int) -> dict:
    log_path = Path(__file__).resolve().parent / "logs" / "gifts.json"
    if not log_path.exists():
        raise FileNotFoundError(f"Log file not found: {log_path}")
    data = json.loads(log_path.read_text(encoding="utf-8") or "[]")
    if not isinstance(data, list):
        raise ValueError("gifts.json has invalid format (expected list).")
    for item in data:
        if isinstance(item, dict) and item.get("id") == log_id:
            return item
    raise ValueError(f"Log entry with id={log_id} not found.")


def _judge_input_from_log(entry: dict) -> JudgeInput:
    history = entry.get("history") or []
    human_msgs = [str(m.get("content", "")) for m in history if isinstance(m, dict) and m.get("role") == "human"]
    ai_msgs = [str(m.get("content", "")) for m in history if isinstance(m, dict) and m.get("role") == "ai"]

    user_context = "\n".join(human_msgs).strip() or "Нет контекста пользователя."
    gift_answer = (
        entry.get("ready_to_search_message")
        or entry.get("pre_ready_message")
        or (ai_msgs[-1] if ai_msgs else "")
    )
    if not gift_answer:
        gift_answer = "Пустой ответ модели."
    return JudgeInput(user_context=user_context, gift_answer=gift_answer)


def _print_scores(result: JudgeScores) -> None:
    print("Оценки (1–5):")
    print(f"  relevance_to_recipient:   {result.relevance_to_recipient}")
    print(f"  fit_for_occasion:         {result.fit_for_occasion}")
    print(f"  budget_fit:               {result.budget_fit}")
    print(f"  specificity_practicality: {result.specificity_practicality}")
    print(f"  diversity_originality:    {result.diversity_originality}")
    print(f"  explanation_quality:      {result.explanation_quality}")
    print("\nКомментарий:")
    print(f"  {result.overall_comment}")
    print("\nРекомендации по улучшению:")
    if result.improvement_suggestions:
        for i, tip in enumerate(result.improvement_suggestions, 1):
            print(f"  {i}. {tip}")
    else:
        print("  Нет рекомендаций.")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Judge CLI для оценки ответа gift-ассистента по id лога.")
    parser.add_argument("--id", type=int, help="ID записи из logs/gifts.json для оценки (если не указать, спросим).")
    parser.add_argument("--model", type=str, default=DEFAULT_MODEL, help="Модель судьи (по умолчанию mistralai/mistral-7b-instruct).")
    args = parser.parse_args()

    try:
        _require_api_key()
    except RuntimeError as e:
        print(f"[ERROR] {e}")
        sys.exit(1)

    log_id = args.id
    if log_id is None:
        raw = input("Введите id лога из logs/gifts.json: ").strip()
        try:
            log_id = int(raw)
        except Exception:
            print("[ERROR] Неверный id (нужно целое число).")
            sys.exit(1)

    try:
        entry = _load_log_entry(log_id)
        judge_input = _judge_input_from_log(entry)
    except Exception as e:
        print(f"[ERROR] Не удалось загрузить лог {log_id}: {e}")
        sys.exit(1)

    try:
        result = evaluate_gift_answer(judge_input.user_context, judge_input.gift_answer, model=args.model)
    except Exception as e:
        print(f"[ERROR] Failed to evaluate: {e}")
        sys.exit(1)

    _print_scores(result)
