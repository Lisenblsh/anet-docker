
ARG APP_VERSION
ARG REPO

#FROM git.lisenblsh.art/lisenblsh/anet-keygen:${APP_VERSION}
FROM ${REPO}/lisenblsh/anet-keygen:${APP_VERSION}

WORKDIR /app

COPY . .
RUN apt-get update && \
    apt-get install -y curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*
RUN chmod +x /app/create_server_conf.sh

CMD ["./create_server_conf.sh"]
