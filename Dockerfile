# syntax=docker/dockerfile:1.7

############################
# 🏗️ Stage 1 — Builder
############################
FROM node:lts-slim AS builder

RUN apt-get update && apt-get install -y \
    python3 \
    python3-venv \
    python3-pip \
    build-essential \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV PNPM_HOME=/data/pnpm \
    NPM_CONFIG_PREFIX=/data/global \
    PATH="/data/pnpm:/data/global/bin:/data/venv/bin:/usr/local/bin:$PATH"

RUN mkdir -p /data/pnpm /data/global /data/venv
RUN python3 -m venv /data/venv

RUN corepack enable && corepack prepare pnpm@latest --activate

RUN pnpm add -g better-sqlite3 @tobilu/qmd


############################
# 🚀 Stage 2 — Runtime
############################
FROM node:lts-slim

ENV NODE_ENV=production \
    APP_DATA=/data \
    PNPM_HOME=/data/pnpm \
    NPM_CONFIG_PREFIX=/data/global \
    PATH="/data/pnpm:/data/global/bin:/data/venv/bin:/usr/local/bin:$PATH" \
    \
    MOLTIS_PASSWORD=admin \
    MOLTIS_DATA_DIR=/data \
    MOLTIS_CONFIG_DIR=/data/config \
    MOLTIS_NO_TLS=true \
    MOLTIS_DEPLOY_PLATFORM=cloud

RUN apt-get update && apt-get install -y \
    python3 \
    python3-venv \
    sqlite3 \
    curl \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Moltis (.deb, dynamic version-safe)
RUN set -eux; \
    TAG=$(curl -fsSL https://api.github.com/repos/moltis-org/moltis/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/'); \
    VERSION=$(echo "$TAG" | sed 's/^v//'); \
    URL="https://github.com/moltis-org/moltis/releases/download/${TAG}/moltis_${VERSION}_amd64.deb"; \
    \
    curl -fL "$URL" -o moltis.deb; \
    dpkg -i moltis.deb || apt-get -f install -y; \
    rm -f moltis.deb

COPY --from=builder /data /data

RUN mkdir -p /data/config && chmod -R 777 /data

WORKDIR /data
VOLUME ["/data"]

EXPOSE 13131

CMD sh -c "moltis --bind 0.0.0.0 --port ${PORT:-13131}"
