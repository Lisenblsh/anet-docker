FROM anet-keygen:latest

WORKDIR /app

COPY . .
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/*
RUN chmod +x /app/create_server_conf.sh

CMD ["./create_server_conf.sh"]
