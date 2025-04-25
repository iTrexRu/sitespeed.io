FROM node:18-slim

# Устанавливаем минимальные зависимости поэтапно
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    python3-pip \
    make \
    g++ \
    ffmpeg && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Устанавливаем браузеры отдельно
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    firefox-esr && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Устанавливаем sitespeed.io
RUN npm install -g sitespeed.io

# Устанавливаем Express для API
WORKDIR /usr/src/app
RUN npm init -y && npm install express

# Копируем server.js
COPY server.js /usr/src/app/server.js

# Проверяем установку
RUN echo "Node version:" && node --version && \
    echo "Sitespeed.io version:" && sitespeed.io --version && \
    echo "Files in /usr/src/app:" && ls -la /usr/src/app

# Открываем порт
EXPOSE 3000

# Запускаем сервер
CMD ["node", "server.js"]
