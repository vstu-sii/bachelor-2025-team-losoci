# 📘 README — Инструкция по запуску проекта

## 🧭 Описание проекта

Проект состоит из следующих компонентов:

* **Backend** — серверная часть приложения
* **PostgreSQL** — основная база данных
* **PgAdmin** — веб-интерфейс для управления БД
* **Redis** — кеш и in-memory хранилище
* **Redis Exporter** — метрики Redis для Prometheus
* **RedisInsight** — визуальный интерфейс Redis

Все контейнеры объединены в сеть `monitoring_net` для взаимодействия между ними.

---

## ⚙️ Требования

Перед запуском убедись, что установлено:

* Docker Desktop
* Docker Compose
* (для Windows) Radmin VPN — для сетевого доступа между машинами

---

## 📂 Структура проекта

```
project-root/
│
├─ .env
├─ docker-compose.<env>.yml
└─ README.md
```

---

## 🌐 Настройка Alertmanager и Langfuse

Перед первым запуском создайте конфигурацию Alertmanager:

```yaml
global:
  resolve_timeout: 5m

route:
  receiver: 'yandex-email'
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 30s
  repeat_interval: 1h

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

Установите Langfuse по инструкции: [https://langfuse.com/self-hosting/deployment/docker-compose](https://langfuse.com/self-hosting/deployment/docker-compose) и сгенерируйте ключи для подключения.

---

## 🚀 Запуск окружения

1️⃣ Запустить все сервисы:

```bash
docker compose -f docker-compose.yml up -d
```

2️⃣ Проверить состояние контейнеров:

```bash
docker ps
```

3️⃣ (Опционально) Создать файл уведомлений для Alertmanager.

---

## 🧠 Проверка работы

| Сервис         | Описание            | URL                                                            |
| -------------- | ------------------- | -------------------------------------------------------------- |
| Backend API    | Основной API-сервер | [http://localhost:13000](http://localhost:13000)               |
| PostgreSQL     | Подключение к БД    | [http://localhost:15432](http://localhost:15432)               |
| PgAdmin        | Веб-интерфейс БД    | [http://localhost:5050](http://localhost:5050)                 |
| RedisInsight   | Веб-интерфейс Redis | [http://localhost:5540](http://localhost:5540)                 |
| Redis Exporter | Метрики Redis       | [http://localhost:9121/metrics](http://localhost:9121/metrics) |

---

## 🧩 Подключение коллег через Radmin VPN

Если вы и другие разработчики находитесь в одной Radmin VPN-сети, контейнеры будут доступны по вашему Radmin IP.

Пример для IP `26.81.6.105`:

| Сервис       | URL                                                  |
| ------------ | ---------------------------------------------------- |
| Backend      | [http://26.81.6.105:13000](http://26.81.6.105:13000) |
| PgAdmin      | [http://26.81.6.105:5050](http://26.81.6.105:5050)   |
| RedisInsight | [http://26.81.6.105:5540](http://26.81.6.105:5540)   |

> Убедитесь, что Docker Desktop и Firewall разрешают входящие подключения.

---

## 🧹 Полезные команды

| Команда                               | Назначение                              |
| ------------------------------------- | --------------------------------------- |
| docker ps                             | Показать запущенные контейнеры          |
| docker logs <container>               | Просмотр логов контейнера               |
| docker compose down -v                | Остановить контейнеры и удалить volumes |
| docker exec -it <container> bash      | Войти в контейнер                       |
| docker network inspect monitoring_net | Проверить контейнеры в сети             |

---

## 💡 Рекомендации

* Для Windows с Docker Desktop включите **Use WSL 2 based engine**.
* При изменении `.env` выполняйте `docker compose down`, затем `docker compose up -d`.
* Redis запускается без отдельного ACL-файла, пароль задаётся через `.env`.

---

👨‍💻 **Автор:**
Инфраструктура подготовлена для совместной разработки через Docker + Radmin VPN.
