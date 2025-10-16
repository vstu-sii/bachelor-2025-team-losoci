# LosoCi ai_gift_assistant

Проект для отслеживания привычек с фронтендом, бэкендом, базой данных Postgres и Ollama (с поддержкой GPU).  

---

## Содержание

- [Описание проекта](#описание-проекта)
- [Требования](#требования)
- [Установка](#установка)
- [Структура проекта](#структура-проекта)

---

## Описание проекта

Этот проект состоит из следующих компонентов:  

- **Frontend** – приложение на Node.js + Vite, доступно на порту `5173`.  
- **Backend** – сервер на Node.js, доступен на порту `13000`.  
- **Postgres** – база данных для хранения данных приложения, порт `15432`.  
- **Ollama** – сервис для работы с LLM, использующий GPU (порт `11434`).  

Все сервисы запускаются через Docker Compose и используют volumes для сохранения данных между перезапусками.

---

## Требования

- Docker >= 24.x  
- Docker Compose >= 2.x  
- GPU с драйверами NVIDIA (для Ollama)  
- [NVIDIA Container Toolkit](https://developer.nvidia.com/cuda-toolkit) 

---

## Установка

1. Клонируем репозиторий
2. Создаем папки в корневой директории проекта , при условии что они отсутсвуют /frontend и /backend
3. в папке ./frontend создаем файл с именем Dockerfile и добавляем туда код:
```Dockerfile
FROM node:22
WORKDIR /app
RUN npm init -y && \
    npm install vue@latest && \
    npm install -D vite @vitejs/plugin-vue && \
    npm set-script dev "vite" && \
    npm set-script build "vite build" && \
    npm set-script preview "vite preview"
COPY . .
EXPOSE 5173
CMD ["npm", "run", "dev"]
```
4. в папке ./backend создаем файл с именем Dockerfile и добавляем туда код:
```Dockerfile
FROM node:22
WORKDIR /app
RUN npm init -y && \
    npm install express && \
    npm set-script dev "node index.js"
COPY . .
EXPOSE 13000
CMD ["npm", "run", "dev"]
```
5. Проверка доступа графическому процессору в [докере](https://docs.docker.com/desktop/features/gpu/) должна отобазится в терминале какая виедеокарта доступна :

```bash
docker run --rm -it --gpus=all nvcr.io/nvidia/k8s/cuda-sample:nbody nbody -gpu -benchmark
```
6. Запуск сборки докер контейнеров:
```bash
docker network create monitoring_net
docker-compose up -d
```
7. [развёртывание Langfuse локально](https://langfuse.com/self-hosting/deployment/docker-compose) 
```bash
git clone https://github.com/langfuse/langfuse.git
cd langfuse
docker compose up
```

8. переменные для monitoriong/.env
```bash
# Кому отправлять уведомления
ALERT_TO=example1@mail.com,example2@mail.com
# С какого ящика отправлять
ALERT_FROM=no-reply@example.com
# SMTP сервер
SMTP_HOST=smtp.example.com
SMTP_PORT=587

# Данные для авторизации SMTP
SMTP_USER=no-reply@example.com
SMTP_PASS=your_smtp_password_here
```

## структура-проекта
```bash
ai_gift_assistant/
├─ frontend/
│  ├─ Dockerfile
│  ├─ package.json
│  ├─ .env
│  └─ ...
├─ backend/
│  ├─ Dockerfile
│  ├─ package.json
│  ├─ .env
│  └─ ...
├─ docker-compose.dev.yml
└─ README.md
```

