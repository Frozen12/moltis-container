# syntax=docker/dockerfile:1.7

FROM node:lts-alpine

# Core environment
ENV NODE_ENV=production \
    APP_DATA=/data \
    PNPM_HOME=/data/pnpm \
    NPM_CONFIG_PREFIX=/data/global \
    PATH="/data/pnpm:/data/global/bin:/data/venv/bin:/root/.local/bin:/usr/local/bin:$PATH" \
    \
    MOLTIS_PASSWORD=admin \
    MOLTIS_DATA_DIR=/data \
    MOLTIS_CONFIG_DIR=/data/config \
    MOLTIS_NO_TLS=true \
    MOLTIS_DEPLOY_PLATFORM=vultr \
    \
    # 🔥 pnpm critical fixes
    PNPM_IGNORE_SCRIPTS=false \
    PNPM_ENABLE_PRE_POST_SCRIPTS=true

# Install deps
RUN apk add --no-cache \
    python3 \
    py3-pip \
    git \
    curl \
    bash \
    sqlite \
    chromium \
    libstdc++ \
    libgcc \
    ca-certificates \
    && apk add --no-cache --virtual .build-deps \
    python3-dev \
    build-base

# Create persistent dirs
RUN mkdir -p /data/pnpm /data/global /data/venv /data/config \
    && chmod -R 777 /data

# Python venv
RUN python3 -m venv /data/venv

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Ensure scripts allowed
RUN pnpm config set ignore-scripts false \
    && pnpm config set enable-pre-post-scripts true

# Install Moltis
RUN curl -fsSL https://www.moltis.org/install.sh | sh

# Install better-sqlite3 and qmd
RUN pnpm add -g better-sqlite3 @tobilu/qmd


# Remove build deps (after native compiled)
RUN apk del .build-deps

# Cleanup
RUN rm -rf /root/.cache /tmp/*

WORKDIR /data
VOLUME ["/data"]

EXPOSE 13131

CMD ["sh", "-c", "moltis --bind 0.0.0.0 --port ${PORT:-13131}"]
