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
    # 🔥 pnpm fix
    PNPM_IGNORE_SCRIPTS=false

# Install runtime + build deps (split for cleanup)
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

# Create persistent structure
RUN mkdir -p /data/pnpm /data/global /data/venv /data/config \
    && chmod -R 777 /data

# Python venv
RUN python3 -m venv /data/venv

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Allow native builds
RUN pnpm config set ignore-scripts false \
    && pnpm config set enable-pre-post-scripts true

# Install Moltis
RUN curl -fsSL https://www.moltis.org/install.sh | sh

# Install qmd + build native modules
RUN pnpm add -g @tobilu/qmd && pnpm rebuild

# 🔥 Remove build dependencies (size reduction)
RUN apk del .build-deps

# Clean cache
RUN rm -rf /root/.cache /tmp/*

# Working directory
WORKDIR /data

# Volume
VOLUME ["/data"]

# Expose port
EXPOSE 13131


# Start Moltis
CMD ["moltis", "--bind", "0.0.0.0", "--port", "13131"]
