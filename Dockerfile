# Moltis for ClawCloud — root user, single persistent volume
# Uses pre-built moltis release from GitHub

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

# Install moltis from GitHub releases
RUN curl -fLs "https://api.github.com/repos/moltis-org/moltis/releases/latest" | \
    python3 -c "import sys,json,re; d=json.load(sys.stdin); t=d['tag_name']; v=re.sub(r'^v','',t); print(t,v)" > /tmp/tag.txt && \
    TAG=$(cut -d' ' -f1 /tmp/tag.txt) && \
    VERSION=$(cut -d' ' -f2 /tmp/tag.txt) && \
    curl -fL "https://github.com/moltis-org/moltis/releases/download/$TAG/moltis_${VERSION}_amd64.deb" -o /tmp/moltis.deb && \
    dpkg -i /tmp/moltis.deb || apt-get -f install -y && \
    rm -f /tmp/moltis.deb /tmp/tag.txt

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
ENV MOLTIS_LOG_LEVEL=debug

# SSH is built into moltis gateway on port 1455
EXPOSE 13131 13132 1455

WORKDIR /home/moltis

COPY init.sh /init.sh
RUN chmod +x /init.sh

ENTRYPOINT ["moltis"]
CMD ["--bind", "0.0.0.0", "--port", "13131"]
