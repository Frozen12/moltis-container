# Moltis for ClawCloud — root user, single persistent volume
# Built on official moltis multi-stage build
FROM rust:bookworm AS builder

WORKDIR /build
RUN rustup install nightly-2025-11-30 && rustup default nightly-2025-11-30

COPY Cargo.toml Cargo.lock ./
COPY crates ./crates
COPY apps/courier ./apps/courier
COPY wit ./wit

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && \
    apt-get install -yqq --no-install-recommends cmake build-essential libclang-dev pkg-config git && \
    rm -rf /var/lib/apt/lists/*

# Build Tailwind CSS
RUN ARCH=$(uname -m) && \
    case "$ARCH" in x86_64) TW="tailwindcss-linux-x64";; aarch64) TW="tailwindcss-linux-arm64";; esac && \
    curl -sLO "https://github.com/tailwindlabs/tailwindcss/releases/latest/download/$TW" && \
    chmod +x "$TW" && \
    cd crates/web/ui && TAILWINDCSS="../../../$TW" ./build.sh

# Build WASM components
RUN rustup target add wasm32-wasip2 && \
    cargo build --target wasm32-wasip2 -p moltis-wasm-calc -p moltis-wasm-web-fetch -p moltis-wasm-web-search --release

ARG MOLTIS_VERSION
ENV MOLTIS_VERSION=${MOLTIS_VERSION}
RUN cargo build --release -p moltis --features wasm

# Runtime stage
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash

# Base dependencies + Node.js 22 + pnpm via corepack + uv
RUN apt-get update -qq && \
    apt-get install -yqq --no-install-recommends \
        ca-certificates chromium curl gnupg libgomp1 sudo tmux vim-tiny \
        build-essential cmake libclang-dev pkg-config git && \
    rm -rf /var/lib/apt/lists/*

# Node.js 22 LTS
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
    > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update -qq && \
    apt-get install -yqq --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# pnpm via corepack
RUN corepack enable && corepack prepare pnpm@latest --activate

# uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    ln -sf /root/.local/bin/uv /usr/local/bin/uv

# Install extra packages an autonomous agent might need (no human tools)
RUN apt-get update -qq && \
    apt-get install -yqq --no-install-recommends \
        poppler-utils unoconv html2text w3m jq ripgrep fzf rsync gh ncdu duf python3 pip && \
    rm -rf /var/lib/apt/lists/*

# Copy binary and assets from builder
COPY --from=builder /build/target/release/moltis /usr/local/bin/moltis
COPY --from=builder /build/crates/web/src/assets /usr/share/moltis/web
COPY --from=builder /build/target/wasm32-wasip2/release/moltis_wasm_calc.wasm /usr/share/moltis/wasm/
COPY --from=builder /build/target/wasm32-wasip2/release/moltis_wasm_web_fetch.wasm /usr/share/moltis/wasm/
COPY --from=builder /build/target/wasm32-wasip2/release/moltis_wasm_web_search.wasm /usr/share/moltis/wasm/

# Single persistent volume for all state
# - /data/moltis-config  → gateway config
# - /data/moltis-data    → app data (sessions, etc.)
# - /data/pnpm-store     → pnpm store (PNPM_HOME also set below)
# - /data/uv-cache       → uv cache
VOLUME ["/data"]

# Env vars for persistent volume paths
ENV MOLTIS_CONFIG_DIR=/data/moltis-config
ENV MOLTIS_DATA_DIR=/data/moltis-data
ENV PNPM_HOME=/data/pnpm-store
ENV PNPM_STORE_DIR=/data/pnpm-store/store
ENV UV_CACHE_DIR=/data/uv-cache
ENV UV_LINK_MODE=copy
ENV PATH="/data/pnpm-store/global/bin:/root/.local/bin:${PATH}"

# Disable sandbox and docker (ClawCloud doesn't provide socket)
ENV MOLTIS_SANDBOX_ENABLED=false
ENV MOLTIS_DOCKER_ENABLED=false

# Gateway token — user replaces this before deploy
ENV MOLTIS_GATEWAY_TOKEN=changeme_set_your_token_here

# Port config (moltis default)
ENV MOLTIS_PORT=13131
ENV MOLTIS_HOST=0.0.0.0

# SSH is built into moltis gateway on port 1455
EXPOSE 13131 13132 1455

WORKDIR /home/moltis

ENTRYPOINT ["moltis"]
CMD ["--bind", "0.0.0.0", "--port", "13131"]