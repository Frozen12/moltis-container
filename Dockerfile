FROM node:lts-alpine

# Core environment
ENV NODE_ENV=production \
    APP_DATA=/data \
    PNPM_HOME=/data/pnpm \
    NPM_CONFIG_PREFIX=/data/global \
    PATH="/data/pnpm:/data/global/bin:/data/venv/bin:/root/.local/bin:/usr/local/bin:$PATH" \
    \
    # 🔥 Moltis config
    MOLTIS_PASSWORD=admin \
    MOLTIS_DATA_DIR=/data \
    MOLTIS_CONFIG_DIR=/data/config \
    MOLTIS_NO_TLS=true \
    MOLTIS_DEPLOY_PLATFORM=vultr

# Install dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    python3-dev \
    build-base \
    git \
    curl \
    bash

# Create persistent structure + fix permissions
RUN mkdir -p /data/pnpm /data/global /data/venv /data/config \
    && chmod -R 777 /data

# Python venv (persistent)
RUN python3 -m venv /data/venv

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# 🔥 Install Moltis via official script
RUN curl -fsSL https://www.moltis.org/install.sh | sh

# Install qmd globally (persistent)
RUN pnpm add -g @tobilu/qmd

# Working directory
WORKDIR /data

# Volume
VOLUME ["/data"]

# Expose port
EXPOSE 13131

# Start Moltis
CMD ["moltis", "--bind", "0.0.0.0", "--port", "13131"]