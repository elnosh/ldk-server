FROM rust:1.85-slim-bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY . .
RUN cargo build --release --package ldk-server

FROM debian:bookworm-slim

RUN useradd --system --create-home --shell /bin/false ldk-server \
    && mkdir /data /config \
    && chown ldk-server:ldk-server /data /config

COPY --from=builder /build/target/release/ldk-server /usr/local/bin/ldk-server

ENV LDK_SERVER_NODE_REST_SERVICE_ADDRESS=0.0.0.0:3002
ENV LDK_SERVER_STORAGE_DIR_PATH=/data

EXPOSE 3001 3002

VOLUME ["/data"]

USER ldk-server

ENTRYPOINT ["/usr/local/bin/ldk-server"]
CMD []
