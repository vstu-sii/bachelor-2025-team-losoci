# Infrastructure Guide — AI Gift Assistant

Этот документ описывает инфраструктуру проекта, инструкции по запуску, troubleshooting и быстрые подсказки для команды.

---

## Содержание

1. [Описание проекта](#описание-проекта)
2. [Архитектура инфраструктуры](#архитектура-инфраструктуры)
3. [Установка и запуск dev окружения](#установка-и-запуск-dev-окружения)
4. [Troubleshooting guide](#troubleshooting-guide)
5. [Cheat sheet для команды](#cheat-sheet-для-команды)
6. [Структура проекта](#структура-проекта)

---

## Описание проекта

Проект **AI Gift Assistant** 

Основные компоненты:

- **Frontend** — приложение на Node.js + Vite, порт `5173`.
- **Backend** — сервер на Node.js, порт `13000`.
- **Postgres** — база данных приложения, порт `15432`.
- **Ollama** — сервис LLM с поддержкой GPU, порт `11434`.
- **Redis** — кэш и очередь задач, порт `6378`.
- **Monitoring stack** — Prometheus, Grafana, Loki, Promtail, Alertmanager для мониторинга и алертинга.

Все сервисы запускаются через Docker Compose и используют volume для сохранения данных между перезапусками.

---

## Архитектура инфраструктуры

```
[Frontend] ---> [Backend] ---> [Postgres]
|
+--> [Redis]
|
+--> [Ollama (GPU)]

Monitoring stack:
[Prometheus] <-- [Promtail]
[Grafana] <--> [Prometheus/Loki]
[Alertmanager] <-- [Prometheus Alerts]
```


- **Docker сеть**: `monitoring_net` (external)
- **Volumes**: `postgres_data`, `redis_data`, `ollama_data`, `loki_data`

---

## Установка и запуск dev окружения

1. **Клонируем репозиторий**
```bash
git clone <репозиторий>
cd ai_gift_assistant
```
2. Проверка доступа к GPU (для Ollama)
```bash
docker run --rm -it --gpus=all nvcr.io/nvidia/k8s/cuda-sample:nbody nbody -gpu -benchmark
```
3. Создание сети Docker 
```bash
docker network create monitoring_net
```
4. Запуск сервисов через Docker Compose
```bash
docker-compose -f docker-compose.dev.yml up -d
```
5. Переменные окружения для мониторинга (monitoring/.env)
``` bash
# Кому отправлять уведомления
ALERT_TO=example1@mail.com,example2@mail.com
# С какого ящика отправлять
ALERT_FROM=no-reply@example.com
# SMTP сервер
SMTP_HOST=smtp.example.com
SMTP_PORT=587
# SMTP авторизация
SMTP_USER=no-reply@example.com
SMTP_PASS=supersecretpassword
```
6. развёртывание Langfuse
```bash
git clone https://github.com/langfuse/langfuse.git
cd langfuse
docker compose up
```

## Troubleshooting guide
| Проблема                          | Решение                                                                                    |
| --------------------------------- | ------------------------------------------------------------------------------------------ |
| Контейнер не стартует из-за порта | Проверьте `netstat -ano` и убедитесь, что порт свободен                                    |
| Email уведомления не приходят     | Проверьте `.env` и конфигурацию `alertmanager.yml`, тест через Python скрипт `smtptest.py` |
| Loki не стартует                  | Проверьте `config.yaml`, права на директории `/loki` и тома volumes                        |
| Grafana не доступна               | Проверьте порты и переменные `GF_SECURITY_ADMIN_USER/PASSWORD`                             |
| Redis exporter не работает        | Убедитесь, что Redis поднят и `REDIS_ADDR` корректен                                       |

## Cheat sheet для команды
```bash
# Проверка всех контейнеров
docker ps

# Логи Alertmanager
docker logs -f alertmanager

# Логи Grafana
docker logs -f grafana

# Проверка переменных окружения
docker exec -it alertmanager printenv

# Перезапуск одного контейнера
docker restart <container_name>

# Остановка всех сервисов
docker-compose -f docker-compose.dev.yml down
```

## Структура проекта
``` bsah
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
├─ monitoring/
│  ├─ alertmanager/
│  │  └─ alertmanager.yml
│  ├─ loki/
│  │  ├─ config.yaml
│  │  └─ data/
│  ├─ promtail/
│  │  └─ config.yaml
│  ├─ prometheus/
│  │  ├─ prometheus.yml
│  │  └─ rules.yml
│  └─ .env
├─ docker-compose.dev.yml
└─ README.md
```