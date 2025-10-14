### **Таблица users**

| Поле                      | Тип данных   | Описание                           | Индексы      |
| ------------------------- | ------------ | ---------------------------------- | ------------ |
| `id`                      | SERIAL (PK)  | Уникальный идентификатор           | PK           |
| `email`                   | VARCHAR(100) | Электронная почта (уникальная)     | UNIQUE INDEX |
| `password`                | VARCHAR(50)  | Пароль                             | –            |
| `name`                    | VARCHAR(50)  | Имя                                | INDEX        |
| `surname`                 | VARCHAR(50)  | Фамилия                            | INDEX        |
| `birthday`                | DATE         | День рождения                      | -            |
| `gender`                  | VARCHAR(10)  | Пол                                | -            |
| `description`             | TEXT         | Описание                           | –            |
| `telegram_link`           | VARCHAR(100) | Ссылка на Telegram                 | –            |
| `email_confirmed`         | BOOLEAN      | Подтверждение аккаунта через почту | -            |
| `telegram_link_confirmed` | BOOLEAN      | Подтверждение телеграмм-аккаунта   | -            |

---

### **Таблица chats**

| Поле           | Тип данных   | Описание                   | Индексы |
| -------------- | ------------ | -------------------------- | ------- |
| `id`           | SERIAL (PK)  | Уникальный идентификатор   | PK      |
| `title`        | VARCHAR(100) | Название чата              | INDEX   |
| `sender_id`    | INT (FK)     | Владелец чата → `users.id` | INDEX   |
| `recipient_id` | INT (FK)     | Получатель → `users.id`    | INDEX   |

---

### **Таблица messages**

| Поле        | Тип данных  | Описание                                 | Индексы |
| ----------- | ----------- | ---------------------------------------- | ------- |
| `id`        | SERIAL (PK) | Уникальный идентификатор                 | PK      |
| `text`      | TEXT        | Текст сообщения                          | –       |
| `timestamp` | TIMESTAMP   | Время отправки (по умолчанию `NOW()`)    | INDEX   |
| `chat_id`   | INT (FK)    | Чат → `chats.id`                         | INDEX   |
| `role`      | VARCHAR(20) | Роль отправителя: 'user' или 'assistant' | -       |

---

### **Таблица photo**

| Поле      | Тип данных   | Описание                   | Индексы |
| --------- | ------------ | -------------------------- | ------- |
| `id`      | SERIAL (PK)  | Уникальный идентификатор   | PK      |
| `name`    | VARCHAR(100) | Имя/путь фото              | INDEX   |
| `user_id` | INT (FK)     | Владелец фото → `users.id` | INDEX   |

---

### **Таблица importance**

| Поле   | Тип данных  | Описание                 | Индексы      |
| ------ | ----------- | ------------------------ | ------------ |
| `id`   | SERIAL (PK) | Уникальный идентификатор | PK           |
| `name` | VARCHAR(50) | Уровень важности         | UNIQUE INDEX |

---

### **Таблица events**

| Поле            | Тип данных   | Описание                         | Индексы |
| --------------- | ------------ | -------------------------------- | ------- |
| `id`            | SERIAL (PK)  | Уникальный идентификатор         | PK      |
| `title`         | VARCHAR(100) | Название события                 | -       |
| `description`   | TEXT         | Описание события                 | –       |
| `date`          | DATE         | Дата события                     | INDEX   |
| `importance_id` | INT (FK)     | Важность → `importance.id`       | INDEX   |
| `recipient_id`  | INT (FK)     | Получатель                       | INDEX   |
| `completed`     | BOOLEAN      | Выполнено (по умолчанию `FALSE`) | -       |
| `user_id`       | INT (FK)     | Автор события → `users.id`       | INDEX   |

# Формат данных для взаимодействия с AI-сервисом

### Логика работы

1. **Пользователь отправляет сообщение:** Через endpoint `/messages` (POST), сервер сохраняет сообщение в `messages` с `role = 'user'`.
2. **Формирование промпта:** Сервер извлекает историю чата из `messages` (фильтр по `chat_id`, сортировка по `timestamp`), добавляет системный промпт (на основе профиля пользователя из `users`, событий из `events` и т.д.), и формирует запрос к AI-сервису.
3. **Отправка к AI:** Сервер отправляет JSON-запрос к AI-сервису.
4. **Получение ответа:** Сервер парсит ответ, сохраняет его в `messages` с `role = 'assistant'`, и возвращает клиенту (например, через WebSocket или polling для обновления чата).

## Формат отправляемых данных (Запрос к AI-сервису)

Запрос отправляется как HTTP POST на endpoint AI-сервиса . Тело запроса — JSON-объект.

### Пример JSON-запроса

```json
{
    "model": "model_name",
    "messages": [
        {
            "role": "system",
            "content": "You are Gift AI, a helpful assistant for recommending personalized gifts. Use the user's profile: Name - {name}, Surname - {surname}, Birthday - {birthdate}, Description - {description}. Upcoming events: {events_list}. Suggest gifts based on chat history and events."
        },
        {
            "role": "user",
            "content": "Previous user message 1"
        },
        {
            "role": "assistant",
            "content": "Previous assistant response 1"
        },
        // ... (вся история чата из таблицы messages, чередующаяся user/assistant)
        {
            "role": "user",
            "content": "Current user message"
        }
    ],
    "max_tokens": 500,
    "temperature": 0.7,
    "stream": false
}
```

### Описание полей

-   model: Строка, указывающая модель LLM . Обязательно, если сервис поддерживает выбор.
-   messages: Массив объектов, где каждый объект — сообщение:
    -   role: 'system' (для системного промпта, только первый), 'user' (сообщения пользователя), 'assistant' (предыдущие ответы модели).
    -   content: Текст сообщения. Для system — шаблон с плейсхолдерами {name}, {events_list} и т.д., заполняемыми из БД (users и events).
-   max_tokens: Целое число, лимит токенов в ответе (рекомендуется 300-1000, чтобы избежать длинных ответов).
-   temperature: Число (0-1), контролирует случайность (0 — детерминировано, 1 — креативно).
-   stream: Булево, для потоковой передачи ответа (если поддерживается клиентом для реального времени).

Заголовки запроса:

-   Authorization: Bearer <api_key> (API-ключ сервиса).
-   Content-Type: application/json.

## Формат получаемых данных (Ответ от AI-сервиса)

Ответ — JSON-объект. Сервер парсит его, извлекает content из choices[0].message.content и сохраняет как новое сообщение в messages с role = 'assistant'.

### Пример JSON-ответа

```
{
  "id": "chatcmpl-abc123",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Recommended gift: A personalized mug based on your description."
      },
      "finish_reason": "stop"  // Причина завершения
    }
  ],
  "usage": {
    "prompt_tokens": 150,  // Токены в промпте
    "completion_tokens": 50,  // Токены в ответе
    "total_tokens": 200  // Общее
  },
  "created": 1727462400  // Unix-timestamp создания
}
```

### Описание полей

-   id: Строка, уникальный ID ответа (можно сохранить в logs для отладки).
-   choices: Массив (обычно 1 элемент), где:
    -   message.role: 'assistant'.
    -   message.content: Текст ответа — это то, что сохраняется в messages.text.
    -   finish_reason: Строка, причина остановки генерации.
-   usage: Объект с метриками токенов (полезно для мониторинга затрат, можно логировать отдельно).
-   created: Целое число, timestamp (можно использовать для messages.timestamp, если не использовать NOW()).
