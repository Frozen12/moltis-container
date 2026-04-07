# syntax=docker/dockerfile:1.7
FROM node:lts-slim
 
ENV NODE_ENV=production \
    APP_DATA=/data \
    MOLTIS_PASSWORD=admin \
    MOLTIS_DATA_DIR=/data/moltis \
    MOLTIS_CONFIG_DIR=/data/moltis/config \
    MOLTIS_NO_TLS=true \
    MOLTIS_DEPLOY_PLATFORM=cloud

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        python3 \
        sqlite3 \
        curl \
        git \
        ca-certificates \
        tini; \
    \
    # Install uv
    curl -Ls https://astral.sh/uv/install.sh | sh; \
    \
    # Enable corepack + pnpm
    corepack enable; \
    corepack prepare pnpm@latest --activate; \
    \
    # Temporary build-time pnpm setup (safe)
    export PNPM_HOME=/usr/local/pnpm; \
    mkdir -p /usr/local/pnpm; \
    pnpm config set global-bin-dir /usr/local/bin; \
    \
    # Install base tools (system layer)
    pnpm add -g @tobilu/qmd better-sqlite3; \
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

COPY init.sh /init.sh
RUN chmod +x /init.sh

WORKDIR /data
VOLUME ["/data"]

EXPOSE 13131

ENTRYPOINT ["tini", "--"]
CMD ["/init.sh"]
