# api.py
import os
import time
import orjson
from datetime import datetime, timedelta
from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv

from gift_agent import create_gift_agent
from langchain_core.messages import HumanMessage
# #from langfuse.langchain import CallbackHandler
from langfuse import Langfuse

load_dotenv()

# langfuse = Langfuse(
#     public_key=os.getenv("LANGFUSE_PK"),
#     secret_key=os.getenv("LANGFUSE_SK"),
#     host=os.getenv("LANGFUSE_HOST"),
# )

# langfuse_handler = CallbackHandler()

app = FastAPI(title="Gift Agent API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

agent = create_gift_agent(model_name=os.getenv("MODEL_NAME"))

LOG_DIR = Path(__file__).resolve().parent / "logs"
LOG_FILE = LOG_DIR / "logs.txt"
LOG_DIR.mkdir(exist_ok=True)
GIFT_LOG_FILE = LOG_DIR / "gifts.json"


def _write_log(event: str, request: Request, status: int | str, duration_ms: float | None = None, error: str | None = None):
    ts = (datetime.utcnow() + timedelta(hours=3)).strftime("%m.%d %H:%M:%S")
    dur_str = f"{duration_ms:.2f}ms" if duration_ms is not None else "-"
    client = getattr(request, "client", None)
    client_ip = getattr(client, "host", "-") if client else "-"
    line = f"[{ts}] {request.method} {request.url.path} -> status={status} dur={dur_str} client={client_ip} event={event}"
    if error:
        line += f" err={error}"
    with LOG_FILE.open("a", encoding="utf-8") as f:
        f.write(line + "\n")


def _append_gift_log(
    sender_id: str,
    recipient_id: str,
    history: list[dict],
    ready_message: str | None,
    pre_ready_message: str | None,
) -> None:
    GIFT_LOG_FILE.parent.mkdir(exist_ok=True)
    try:
        if GIFT_LOG_FILE.exists():
            raw = GIFT_LOG_FILE.read_bytes()
            items = orjson.loads(raw) if raw else []
            if not isinstance(items, list):
                items = []
        else:
            items = []
    except Exception:
        items = []

    next_id = len(items) + 1
    record = {
        "id": next_id,
        "timestamp": datetime.utcnow().isoformat(),
        "sender_id": sender_id,
        "recipient_id": recipient_id,
        "history": history,
        "ready_to_search_message": ready_message or "",
        "pre_ready_message": pre_ready_message or "",
    }
    items.append(record)
    try:
        GIFT_LOG_FILE.write_bytes(orjson.dumps(items, option=orjson.OPT_INDENT_2))
    except Exception as e:
        print(f"[ERROR] failed to write gift log: {e}")


@app.middleware("http")
async def request_logger(request: Request, call_next):
    start = time.perf_counter()
    _write_log("request_in", request, status="-", duration_ms=None)
    try:
        response = await call_next(request)
        status_code = getattr(response, "status_code", "-")
    except Exception as exc:
        status_code = 500
        elapsed = (time.perf_counter() - start) * 1000
        _write_log("response_out", request, status=status_code, duration_ms=elapsed, error=str(exc))
        raise
    elapsed = (time.perf_counter() - start) * 1000
    _write_log("response_out", request, status=status_code, duration_ms=elapsed)
    return response


class ChatRequest(BaseModel):
    message: str
    sender_id: str
    recipient_id: str


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
            # "callbacks": [langfuse_handler],
            "metadata": {
                "thread_id": thread_id,
                "sender_id": req.sender_id,
                "recipient_id": req.recipient_id,
            },
        },
    )

    messages = result["messages"]
    ai_messages = [m for m in messages if getattr(m, "type", "") == "ai"]

    # полная история (по очереди)
    history: list[dict] = []
    for m in messages:
        history.append(
            {
                "role": getattr(m, "type", "") or "unknown",
                "content": str(getattr(m, "content", "")),
            }
        )

    # находим последнее AI с [READY_TO_SEARCH] и предыдущее AI перед ним
    ready_message: str | None = None
    pre_ready_message: str | None = None
    ready_idx: int | None = None
    for i in range(len(messages) - 1, -1, -1):
        m = messages[i]
        content = getattr(m, "content", "")
        if isinstance(content, str) and "[READY_TO_SEARCH]" in content and getattr(m, "type", "") == "ai":
            ready_message = content
            ready_idx = i
            break
    if ready_idx is not None:
        for j in range(ready_idx - 1, -1, -1):
            m = messages[j]
            content = getattr(m, "content", "")
            if getattr(m, "type", "") == "ai" and isinstance(content, str):
                pre_ready_message = content
                break

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

    # логируем подбор (id растут с 1)
    _append_gift_log(
        sender_id=req.sender_id,
        recipient_id=req.recipient_id,
        history=history,
        ready_message=ready_message,
        pre_ready_message=pre_ready_message,
    )

    return ChatResponse(response=response_text, gifts=gifts)

    # unreachable, keeping type hints happy
    # fmt: off
