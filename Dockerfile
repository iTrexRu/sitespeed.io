FROM node:18

# Устанавливаем зависимости для sitespeed.io
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    make \
    g++ \
    ffmpeg \
    chromium \
    firefox && \
    npm install -g sitespeed.io && \
    apt-get clean

# Устанавливаем Express для API
WORKDIR /usr/src/app
RUN npm init -y && npm install express

# Копируем server.js
COPY server.js /usr/src/app/server.js

# Проверяем наличие файлов и установку
RUN echo "Node version:" && node --version && \
    echo "Sitespeed.io version:" && sitespeed.io --version && \
    echo "Files in /usr/src/app:" && ls -la /usr/src/app

# Открываем порт
EXPOSE 3000

# Запускаем сервер
CMD ["node", "server.js"]
