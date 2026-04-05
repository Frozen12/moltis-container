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
    # 🔥 pnpm fixes (CRITICAL)
    PNPM_IGNORE_SCRIPTS=false \
    PNPM_ENABLE_PRE_POST_SCRIPTS=true

# Install runtime + build deps
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

# Ensure pnpm allows native builds
RUN pnpm config set ignore-scripts false \
    && pnpm config set enable-pre-post-scripts true

# Install Moltis
RUN curl -fsSL https://www.moltis.org/install.sh | sh

# Install qmd
RUN pnpm add -g @tobilu/qmd

# Remove build dependencies (reduce image size)
RUN apk del .build-deps

# Cleanup cache
RUN rm -rf /root/.cache /tmp/*

# Working directory
WORKDIR /data

# Volume
VOLUME ["/data"]

# Expose port
EXPOSE 13131


# Start Moltis
CMD ["sh", "-c", "moltis --bind 0.0.0.0 --port ${PORT:-13131}"]
