import uvicorn
from main import app

if __name__ == "__main__":    
    uvicorn.run(
        app, 
        host="0.0.0.0",  # доступ с любого IP
        port=8080,       # ← ваш порт
        #reload=True      # автоматическая перезагрузка при изменениях
    )
