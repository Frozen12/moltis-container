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
    MOLTIS_DEPLOY_PLATFORM=cloud

# Create non-root user
RUN useradd -m -u 10001 -s /bin/bash moltis

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        python3 \
        sqlite3 \
        curl \
        git \
        ca-certificates \
        tini \
        gosu; \
    \
    # Create persistent dirs
    mkdir -p /data/pnpm /data/global /data/global/bin /data/uv/cache /data/uv/tools; \
    \
    # Install uv
    curl -Ls https://astral.sh/uv/install.sh | sh; \
    \
    # Enable pnpm
    corepack enable; \
    corepack prepare pnpm@latest --activate; \
    \
    # Proper pnpm global config
    pnpm config set global-dir /data/global; \
    pnpm config set global-bin-dir /data/global/bin; \
    \
    # Install node deps
    pnpm add -g better-sqlite3 @tobilu/qmd; \
    \
    # (Optional debug — remove later)
    ls -la /data/global/bin; \
    \
    # Install Moltis
    TAG=$(curl -fsSL https://api.github.com/repos/moltis-org/moltis/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/'); \
    VERSION=${TAG#v}; \
    curl -fL "https://github.com/moltis-org/moltis/releases/download/${TAG}/moltis_${VERSION}_amd64.deb" -o moltis.deb; \
    dpkg -i moltis.deb || apt-get -f install -y; \
    rm -f moltis.deb; \
    \
    # Cleanup
    rm -rf /var/lib/apt/lists/* /root/.cache /tmp/*

# Init script
COPY init.sh /init.sh
RUN chmod +x /init.sh

WORKDIR /data
VOLUME ["/data"]

EXPOSE 13131

ENTRYPOINT ["tini", "--"]
CMD ["/init.sh"]
