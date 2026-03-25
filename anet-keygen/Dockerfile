# STAGE 1: build anet-keygen
FROM rust:latest AS builder

RUN apt-get update && apt-get install -y git

WORKDIR /app

RUN git clone https://github.com/ZeroTworu/anet.git .

WORKDIR /app/anet-keygen

RUN cargo build --release --verbose

# STAGE 2: runtime
FROM debian:bookworm-slim

WORKDIR /app

COPY --from=builder /app/target/release/anet-keygen /app/anet-keygen

RUN chmod +x /app/anet-keygen

#CMD ["./anet-keygen"]
