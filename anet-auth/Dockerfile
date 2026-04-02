# STAGE 1: build anet-auth
FROM rust:latest AS builder

RUN apt-get update && apt-get install -y git

WORKDIR /app

ARG APP_VERSION

RUN git clone --branch ${APP_VERSION} --depth 1 https://github.com/ZeroTworu/anet.git .

WORKDIR /app/anet-auth

RUN cargo build --release

# STAGE 2: runtime
FROM debian:bookworm-slim

WORKDIR /app

COPY --from=builder /app/target/release/anet-auth /app/anet-auth

RUN chmod +x /app/anet-auth

CMD ["./anet-auth"]
