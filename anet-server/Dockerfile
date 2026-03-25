# STAGE 1: build anet-server
FROM rust:latest AS builder

RUN apt-get update && apt-get install -y git protobuf-compiler

WORKDIR /app

RUN git clone https://github.com/ZeroTworu/anet.git .

WORKDIR /app/anet-server

RUN cargo build --release --verbose

# STAGE 2: runtime
FROM debian:bookworm-slim


RUN apt-get update && \
    apt-get install -y ssh && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/target/release/anet-server /app/anet-server

RUN chmod +x /app/anet-server

CMD ["./anet-server", "-c", "/app/config/server.toml"]
