

########################
# Stage 1: build
########################
FROM node:22-alpine AS builder

WORKDIR /app

# ставим git (нужно для clone)
RUN apk add --no-cache git

ARG APP_VERSION
# клонируем репу
RUN git clone --branch ${APP_VERSION} --depth 1 https://github.com/ZeroTworu/anet.git .

# переходим в нужную папку фронта
WORKDIR /app/anet-webui

# зависимости
RUN npm ci

# сборка Vue/Vite
RUN npm run build


########################
# Stage 2: nginx
########################
FROM nginx:1.27-alpine

# чистим дефолт
RUN rm -rf /usr/share/nginx/html/*

# копируем билд
COPY --from=builder /app/anet-webui/dist /usr/share/nginx/html

# nginx конфиг под SPA
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
