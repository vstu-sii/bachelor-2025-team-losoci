import requests
from langfuse import Langfuse
import os
import sys

sys.path.append(os.path.abspath("C:/vuzik/sii/bachelor-2025-team-losoci/ml"))

from prompt_templates import ProfileText

from langfuse import Langfuse
from langchain_ollama import ChatOllama

import os
from dotenv import load_dotenv
load_dotenv()
langfuse = Langfuse(
        secret_key=os.getenv('LANGFUSE_SK'),
        public_key=os.getenv('LANGFUSE_PK'),
        host=os.getenv('LANGFUSE_HOST')
    )
from langchain.agents import create_agent
from langchain_ollama import ChatOllama
from langgraph.checkpoint.memory import InMemorySaver  
from langfuse.langchain import CallbackHandler

model = ChatOllama(
    model="llama3.1",
    validate_model_on_init=True,
    temperature=0.4,
    max_tokens=2048,
    
)

checkpointer = InMemorySaver()
langfuse_handler = CallbackHandler()
pt = ProfileText()

chat_agent = create_agent(
    model,
    system_prompt="ты ассистент",
    checkpointer=checkpointer,
    )

def run_chat_assistant(prompt: str,
                       sender_id: str, 
                       recipient_id: str,):
    
     answer = chat_agent.invoke({"messages": {"role": "human", "content": prompt}}, 
                                config={"configurable": {"thread_id": int(sender_id +recipient_id)},
                                     "callbacks": [langfuse_handler]})
     answer = answer['messages'][-1].content
     return answer
    





from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import uvicorn

app = FastAPI()

class ChatRequest(BaseModel):
    prompt: str
    sender_id: str
    recipient_id: str

class ChatResponse(BaseModel):
    answer: str
    status: str = "success"

@app.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    try:
        answer = run_chat_assistant(
            prompt=request.prompt,
            sender_id=request.sender_id,
            recipient_id=request.recipient_id,
        )
        
        return ChatResponse(answer=answer)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")
    


