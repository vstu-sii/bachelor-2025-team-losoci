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