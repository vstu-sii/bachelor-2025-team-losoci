# Настройка окружений — AI Gift Assistant

## 📌 Цель

Документ описывает конфигурацию окружений (Dev, Staging, Prod), управление переменными окружения, стратегию ротации секретов и планы резервного копирования/восстановления для проекта **AI Gift Assistant**.

---

## ⚙️ Окружения

### 🚧 Dev (локальная разработка)

- Локальный запуск backend: `npm run dev` (Express + TypeScript)
- База данных: локальный **PostgreSQL** в Docker или нативный
- Кэш/очереди: локальный **Redis**
- AI-агент: удалённый или локальный сервер по `AI_CHAT_AGENT_HOST`
- Фронтенд: `npm run dev` (Vite + Vue)
- JWT ключи — тестовые
- Email — тестовые SMTP-аккаунты

Используется для разработки, отладки и локального тестирования.

---

### 🧪 Staging (предпрод)

- Развёртывание на тестовом сервере (Docker Compose)
- База данных: отдельный PostgreSQL (тестовый инстанс)
- Redis в контейнере
- Email — отдельные SMTP-ключи
- JWT-ключи — staging-уровня
- Доступ к API для QA/разработчиков
- Используется для интеграционных тестов, прогонов UI-тестов и проверки функционала перед релизом

---

### 🚀 Prod (продакшен)

- Развёртывание на выделенном сервере или Kubernetes-кластере
- PostgreSQL — боевой инстанс с регулярными бэкапами
- Redis — продакшен-кластер или Docker-контейнер с персистентностью
- Все JWT-ключи и SMTP-пароли хранятся в секрет-менеджере
- Ротация токенов и регулярные обновления контейнеров

---

## 🔑 Environment Variables

Ниже перечислены ключевые переменные окружения, используемые в проекте.

### Пример `.env` (back-end):

```env
# JWT
JWT_ACCESS_SECRET=
JWT_REFRESH_SECRET=
JWT_TELEGRAM_SECRET=

# Backend
SERVER_URL=

# PostgreSQL
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=
POSTGRES_HOST=
POSTGRES_PORT=

# Redis
REDIS_PORT=
REDIS_HOST=
REDIS_EXPORTER_PORT=
REDIS_USER=
REDIS_PASSWORD=

# Email
MAIL_ADDRESS=
MAIL_PASSWORD=
MAIL_PASSWORD2=
MAIL_SMTP=smtp.mail.ru
MAIL_PORT=
MAIL_SECURE=true
EMAIL_CONFIRM_URL=
EMAIL_RESET_PASSWORD_URL=

# Telegram
TG_BOT_TOKEN=
BOT_USERNAME=

# AI Agent
AI_CHAT_AGENT_HOST=

# Frontend
CLIENT_URL=
```

### Пример `.env` (front-end):

```
VITE_SERVER_URL=
VITE_AI_SERVER_URL=
```

### Пример `.env` (AI)

```
LANGFUSE_SK =
LANGFUSE_PK =
LANGFUSE_HOST =
MODEL_NAME =
SEARX_URL =
```

### Пример `.env` (мониторинг)

```
GF_ADMIN_USER=
GF_ADMIN_PASSWORD=
```

### Пример файла `alertmanager.yml` (уведомления)

```
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 1h
  receiver: 'yandex-email'

receivers:
  - name: 'yandex-email'
    email_configs:
      - to: '${ALERT_TO}'
        from: '${ALERT_FROM}'
        smarthost: '${SMTP_HOST}:${SMTP_PORT}'
        auth_username: '${SMTP_USER}'
        auth_identity: '${SMTP_USER}'
        auth_password: '${SMTP_PASS}'
        require_tls: true
```

## 🧩 Политика окружений

### **Dev**

- Тестовые ключи.
- Упрощённая безопасность.
- Локальные SMTP/Telegram токены.
- Прямой доступ к .env разрешён.

### **Staging**

- Отдельные SMTP-ключи.
- Ограниченные права PostgreSQL/Redis.
- Ограниченный токен Telegram-бота.
- .env хранится в зашифрованном виде.

### **Prod**

- Все ключи — строго через Secret Manager:
  - Docker Secrets
  - Vault
  - Kubernetes Secrets
- Прямой доступ к .env запрещён.
- Полная изоляция сервисов.

---

# 🔒 Secrets Rotation

- Все чувствительные данные:
  - JWT-ключи
  - SMTP-пароли
  - Telegram-токен
  - Redis-пароли
  - PostgreSQL-пароли  
    — хранятся в **Secret Storage**.

### Политика:

- Ротация каждые **90 дней**.
- CI/CD автоматически сигнализирует об истекающих ключах.
- Прямой доступ имеют только:
  - DevOps
  - CI/CD Pipeline

---

# 💾 Backup и Recovery

## 📦 Backup (резервное копирование)

### PostgreSQL

- Ежедневный дамп (`pg_dump`).
- Еженедельный off-site backup (облако).

### Redis

- Ежедневный **RDB-дамп**.
- Хранение в отдельном зашифрованном хранилище.

### Конфигурации

- `.env`, `docker-compose.yml`.

### Telegram-бот

- Экспорт всех ключей и конфигураций.

---

## ♻️ Recovery (восстановление после сбоя)

1. Восстановление PostgreSQL из последнего стабильного дампа.
2. Восстановление Redis RDB-снимка.
3. Перезапуск сервисов:
   - Backend
   - Redis
   - PostgreSQL
   - Chroma
4. Проверка состояния API.
5. Выполнение smoke-теста:

### 🔍 Smoke-тест:

- регистрация пользователя
- авторизация
- корректность запросов рекомендаций
- работа чатов
- отправка email-подтверждения
- работа Telegram-бота

---

# 📂 Итог

Документ определяет:

- Полную структуру **Dev / Staging / Prod** окружений
- Политику управления переменными окружения
- Механизм ротации секретов
- Процедуры резервного копирования и восстановления
