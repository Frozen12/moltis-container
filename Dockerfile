# syntax=docker/dockerfile:1.7

FROM node:lts-slim

ENV NODE_ENV=production \
    APP_DATA=/data \
    PNPM_HOME=/data/pnpm \
    NPM_CONFIG_PREFIX=/data/global \
    PATH="/data/pnpm:/data/global/bin:/data/venv/bin:/usr/local/bin:$PATH" \
    MOLTIS_PASSWORD=admin \
    MOLTIS_DATA_DIR=/data \
    MOLTIS_CONFIG_DIR=/data/config \
    MOLTIS_NO_TLS=true \
    MOLTIS_DEPLOY_PLATFORM=cloud \
    PNPM_IGNORE_SCRIPTS=false \
    PNPM_ENABLE_PRE_POST_SCRIPTS=true

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        python3-pip \
        build-essential \
        sqlite3 \
        curl \
        git \
        ca-certificates; \
    \
    mkdir -p /data/pnpm /data/global /data/venv /data/config; \
    chmod -R 777 /data; \
    \
    python3 -m venv /data/venv; \
    \
    corepack enable; \
    corepack prepare pnpm@latest --activate; \
    pnpm add -g better-sqlite3 @tobilu/qmd; \
    \
    TAG=$(curl -fsSL https://api.github.com/repos/moltis-org/moltis/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/'); \
    VERSION=$(echo "$TAG" | sed 's/^v//'); \
    URL="https://github.com/moltis-org/moltis/releases/download/${TAG}/moltis_${VERSION}_amd64.deb"; \
    \
    curl -fL "$URL" -o moltis.deb; \
    dpkg -i moltis.deb || apt-get -f install -y; \
    rm -f moltis.deb; \
    \
    apt-get remove -y build-essential python3-pip; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/* /root/.cache /tmp/*

WORKDIR /data
VOLUME ["/data"]

EXPOSE 13131

CMD sh -c "moltis --bind 0.0.0.0 --port ${PORT:-13131}"
