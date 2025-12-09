# ============== STAGE 1: Builder ==============
FROM node:22-alpine AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем только файлы зависимостей (для лучшего кэширования)
COPY package*.json ./
COPY tsconfig.json ./

# Устанавливаем ВСЕ зависимости (включая dev, нужны для сборки)
RUN npm ci --silent

# Копируем исходный код
COPY src ./src

# Собираем TypeScript в JavaScript
RUN npm run build

# ============== STAGE 2: Pruner (удаляем dev-зависимости) ==============
FROM node:22-alpine AS pruner

WORKDIR /app

COPY package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

# Устанавливаем ТОЛЬКО production зависимости (чистим devDependencies)
RUN npm ci --omit=dev --silent && npm cache clean --force

# ============== STAGE 3: Final runtime image ==============
FROM node:22-alpine AS production

# Создаём непривилегированного пользователя
RUN addgroup --gid 1001 nodejs
RUN adduser --system --uid 1001 --ingroup nodejs nodejs

WORKDIR /app

# Копируем только нужное из предыдущего стейджа
COPY --from=pruner --chown=nodejs:nodejs /app ./

# Переключаемся на непривилегированного пользователя
USER nodejs

# Открываем порт (по умолчанию Express слушает 3000, можно переопределить)
EXPOSE 13000

# Переменная окружения для продакшена
# ENV NODE_ENV=production

# Запуск приложения
CMD ["node", "dist/app.js"]