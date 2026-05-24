FROM rust:1.95.0-slim-trixie AS chef

ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    pkg-config \
    libssl-dev \
    clang \
    llvm \
    libclang-dev \
    libsnappy-dev && \
    rm -rf /var/lib/apt/lists/*

RUN cargo install cargo-chef --locked --version 0.1.77

WORKDIR /src

# ---

FROM chef AS planner

COPY checkout/. .

RUN cargo chef prepare --recipe-path recipe.json

# ---

FROM chef AS builder

COPY --from=planner /src/recipe.json recipe.json
RUN cargo chef cook --release --locked --recipe-path recipe.json

COPY checkout/. .
RUN cargo build --release --locked && \
    strip target/release/electrs && \
    cp target/release/electrs /tmp/electrs

# ---

FROM debian:trixie-slim AS runtime

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --system --uid 1000 --create-home --home-dir /data electrs
USER electrs
WORKDIR /data

COPY --from=builder /tmp/electrs /usr/local/bin/electrs

# Electrum protocol
EXPOSE 50001

# Prometheus metrics
EXPOSE 4224

STOPSIGNAL SIGINT

ENTRYPOINT ["electrs"]
