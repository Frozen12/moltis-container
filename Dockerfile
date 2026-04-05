# syntax=docker/dockerfile:1.7

FROM node:lts-slim

ENV NODE_ENV=production \
    APP_DATA=/data \
    PNPM_HOME=/data/pnpm \
    NPM_CONFIG_PREFIX=/data/global \
    UV_CACHE_DIR=/data/uv/cache \
    UV_TOOL_DIR=/data/uv/tools \
    PATH="/data/pnpm:/data/global/bin:/data/uv/tools:/home/moltis/.local/bin:/usr/local/bin:$PATH" \
    MOLTIS_PASSWORD=admin \
    MOLTIS_DATA_DIR=/data/moltis \
    MOLTIS_CONFIG_DIR=/data/moltis/config \
    MOLTIS_NO_TLS=true \
    MOLTIS_DEPLOY_PLATFORM=cloud \
    PNPM_IGNORE_SCRIPTS=false \
    PNPM_ENABLE_PRE_POST_SCRIPTS=true

# Create non-root user
RUN useradd -m -u 10001 -s /bin/bash moltis

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        python3 \
        build-essential \
        sqlite3 \
        curl \
        git \
        ca-certificates \
        tini; \
    \
    # Create persistent directories
    mkdir -p \
        /data/pnpm \
        /data/global \
        /data/config \
        /data/uv/cache \
        /data/uv/tools; \
    \
    chown -R moltis:moltis /data; \
    \
    # Install uv
    curl -Ls https://astral.sh/uv/install.sh | sh; \
    \
    # Enable pnpm
    corepack enable; \
    corepack prepare pnpm@latest --activate; \
    \
    # Install global node deps
    pnpm add -g better-sqlite3 @tobilu/qmd; \
    \
    # Install Moltis
    TAG=$(curl -fsSL https://api.github.com/repos/moltis-org/moltis/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/'); \
    VERSION=$(echo "$TAG" | sed 's/^v//'); \
    URL="https://github.com/moltis-org/moltis/releases/download/${TAG}/moltis_${VERSION}_amd64.deb"; \
    \
    curl -fL "$URL" -o moltis.deb; \
    dpkg -i moltis.deb || apt-get -f install -y; \
    rm -f moltis.deb; \
    \
    # Cleanup
    apt-get remove -y build-essential; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/* /root/.cache /tmp/*

WORKDIR /data
VOLUME ["/data"]

USER moltis

EXPOSE 13131

# Proper init system
ENTRYPOINT ["tini", "--"]

# Run qmd as managed background + moltis as main
CMD ["sh", "-c", "qmd & exec moltis --bind 0.0.0.0 --port ${PORT:-13131}"]
