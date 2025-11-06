# 📘 README — Инструкция по запуску проекта

## 🧭 Описание проекта
Этот проект состоит из следующих компонентов:
- **Backend** — серверная часть приложения  
- **PostgreSQL** — основная база данных  
- **PgAdmin** — веб-интерфейс для управления БД  
- **Redis** — кеш и in-memory хранилище  
- **Redis Exporter** — метрики Redis для Prometheus  
- **RedisInsight** — визуальный интерфейс Redis  

Все контейнеры связаны через общую сеть `monitoring_net`, чтобы видеть друг друга.

---

## ⚙️ Требования

Перед запуском убедись, что установлено:
- Docker Desktop  
- Docker Compose  
- (для Windows) Radmin VPN — для сетевого доступа между машинами

---

## 📂 Структура проекта

```
project-root/
│
├─ .env
├─ docker-compose.<...>.yml
└─ README.md
```

---

## 🔑 Настройки окружения (.env)

```env
# Postgres
POSTGRES_USER=dev_user
POSTGRES_PASSWORD=dev_password
POSTGRES_DB=example_db

PGADMIN_EMAIL=admin@example.com
PGADMIN_PASSWORD=example_pass

# Redis
REDIS_PORT=6379
REDIS_EXPORTER_PORT=9121
REDIS_USER=test_user
REDIS_PASSWORD=test_password_123

# Frontend/Backend
FRONTEND_PORT=5173
BACKEND_PORT=13000
DB_PORT=15432
```

---

## 🌐 Создание общей сети Docker

Перед первым запуском:
```bash
docker network create monitoring_net
```

---

## 🚀 Запуск окружения

1️⃣ Запустить что-то отдельное (backend):
```bash
docker compose --env-file .env -f docker-compose.backend.yml up -d
```

2️⃣ Проверить запущенные контейнеры:
```bash
docker ps
```

3️⃣ Посмотреть логи:
```bash
docker compose -f docker-compose.backend.yml logs -f
```

4️⃣ Перезапустить сервис (например, backend):
```bash
docker compose -f docker-compose.backend.yml restart backend
```

5️⃣ Остановить всё:
```bash
docker compose -f docker-compose.backend.yml down
```

---

## 🧠 Проверка работы

| Сервис | Описание | URL |
|--------|-----------|------|
| Backend API | Основной API-сервер | http://localhost:13000 |
| PostgreSQL | Подключение к БД | http://localhost:15432 |
| PgAdmin | Веб-интерфейс БД | http://localhost:5050 |
| RedisInsight | Веб-интерфейс Redis | http://localhost:5540 |
| Redis Exporter | Метрики Redis | http://localhost:9121/metrics |

---

## 🧩 Подключение коллег через Radmin VPN

Если ты и другие разработчики находитесь в одной Radmin VPN-сети,  
то твои контейнеры будут доступны по твоему Radmin IP.

Например, если у тебя в Radmin IP `26.81.6.105`,  
то коллеги смогут подключиться к:

| Сервис | Пример URL |
|--------|-------------|
| Backend | http://26.81.6.105:13000 |
| PgAdmin | http://26.81.6.105:5050 |
| RedisInsight | http://26.81.6.105:5540 |

> Убедись, что Docker Desktop и Firewall разрешают входящие подключения.

---

## 🧹 Полезные команды

| Команда | Назначение |
|----------|-------------|
| docker ps | Показать запущенные контейнеры |
| docker logs <container> | Логи контейнера |
| docker compose down -v | Остановить и удалить volume |
| docker exec -it <container> bash | Войти в контейнер |
| docker network inspect monitoring_net | Проверить контейнеры в сети |

---

## 💡 Рекомендации

- Для Windows с Docker Desktop: включи **Use WSL 2 based engine**.  
- При изменении `.env` делай `docker compose down` и потом `up -d`.  
- Redis запускается без отдельного ACL-файла, пароль задаётся через `.env`.  

---

👨‍💻 **Автор:**  
Инфраструктура подготовлена под совместную разработку через Docker + Radmin VPN.
