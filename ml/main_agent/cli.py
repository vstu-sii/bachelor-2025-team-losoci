"""CLI interface for the simplified gift agent."""
import os
import asyncio
import argparse
from gift_agent import create_gift_agent #, langfuse_handler

async def run_cli(model: str):
    agent = create_gift_agent(model)
    print(f"🎁 Gift Agent (модель {model})\n")
    print("Я помогу подобрать подарок. Просто отвечай на вопросы.\n")

    messages = []
    while True:
        user_input = input("You: ").strip()
        if not user_input:
            continue
        if user_input.lower() in ["exit", "quit", "q"]:
            print("👋 До встречи!")
            break

        messages.append({"role": "user", "content": user_input})
        print("\n🤔 Thinking...\n")

        result = await agent.ainvoke(
                {"messages": messages},
                config={
                    "configurable": {"thread_id": "cli-session"},
                    #"callbacks": [langfuse_handler],
                    "metadata": {"session_id": ""},
                },
            )
        messages = result["messages"]
        last = messages[-1]
        if last.type == "ai":
            print(f"Agent: {last.content}\n")

async def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", "-m", type=str, default=os.getenv("MODEL_NAME"))
    args = parser.parse_args()
    await run_cli(args.model)

if __name__ == "__main__":
    asyncio.run(main())
# 25 лет, мужчина, бильярд спорт, новый год, бюджет средний, думаю подойдет бильярдный набор