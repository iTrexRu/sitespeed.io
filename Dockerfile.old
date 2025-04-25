FROM sitespeedio/webbrowsers:chrome-135.0-firefox-137.0-edge-135.0-1

ARG TARGETPLATFORM=linux/amd64

ENV SITESPEED_IO_BROWSERTIME__XVFB=true
ENV SITESPEED_IO_BROWSERTIME__DOCKER=true
ENV PYTHON=python3

COPY docker/webpagereplay/$TARGETPLATFORM/wpr /usr/local/bin/
COPY docker/webpagereplay/wpr_cert.pem /webpagereplay/certs/
COPY docker/webpagereplay/wpr_key.pem /webpagereplay/certs/
COPY docker/webpagereplay/deterministic.js /webpagereplay/scripts/deterministic.js
COPY docker/webpagereplay/LICENSE /webpagereplay/

RUN apt-get update && apt-get install -y \
    curl \
    libnss3-tools \
    net-tools \
    build-essential \
    iproute2 && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    mkdir -p $HOME/.pki/nssdb && \
    certutil -d $HOME/.pki/nssdb -N && \
    apt-get clean

ENV PATH="/usr/local/bin:${PATH}"

RUN wpr installroot --https_cert_file /webpagereplay/certs/wpr_cert.pem --https_key_file /webpagereplay/certs/wpr_key.pem

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app/
COPY npm-shrinkwrap.json /usr/src/app/
COPY tools/postinstall.js /usr/src/app/tools/postinstall.js
RUN npm install --production && npm cache clean --force 

COPY ./bin/ /usr/src/app/bin/
COPY ./lib/ /usr/src/app/lib/
RUN rm -fR /usr/src/app/node_modules/selenium-webdriver/bin

# Устанавливаем Express для API
RUN npm install express

# Копируем server.js
COPY server.js /usr/src/app/server.js

# Проверяем наличие файлов и Node.js
RUN echo "Node version:" && node --version && \
    echo "NPM version:" && npm --version && \
    echo "Files in /usr/src/app:" && ls -la /usr/src/app

COPY docker/scripts/start.sh /start.sh

# Настраиваем Android и sudo
RUN mkdir -m 0750 /root/.android
ADD docker/adb/insecure_shared_adbkey /root/.android/adbkey
ADD docker/adb/insecure_shared_adbkey.pub /root/.android/adbkey.pub
RUN echo 'ALL ALL=NOPASSWD: /usr/sbin/tc, /usr/sbin/route, /usr/sbin/ip' > /etc/sudoers.d/tc

# Открываем порт для API
EXPOSE 3000

# Запускаем Node.js-сервер вместо start.sh
CMD ["node", "server.js"]
