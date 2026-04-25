# Moltis for ClawCloud — root user, single /data volume
# Base: official moltis image with essential tools added

FROM ghcr.io/moltis-org/moltis:latest

ENV DEBIAN_FRONTEND=noninteractive

# All package installation runs as root
USER root

# Essential tools for autonomous agent (no bloat)
# Removed: curl,ca-certificates (already in base), sudo (root user), ncdu (duf covers it)
RUN apt-get update -qq && \
    apt-get install -yqq --no-install-recommends \
        jq ripgrep fzf rsync gh duf python3 tmux && \
    rm -rf /var/lib/apt/lists/*

# Node.js 24 LTS — download official binary tarball directly (no gpg/apt complexity)
RUN curl -fsSL https://nodejs.org/dist/v24.0.0/node-v24.0.0-linux-x64.tar.gz \
    | tar -xz -C /usr/local --strip-components=1 && \
    ln -sf /usr/local/bin/node /usr/local/bin/nodejs

# pnpm via corepack (runs as root)
# --global-bin-dir /usr/local/bin so the bin symlinks are in PATH
RUN corepack enable && corepack prepare pnpm@latest --activate && \
    mkdir -p /usr/local/lib/pnpm && \
    pnpm add -g mcporter --global-dir /usr/local/lib/pnpm --global-bin-dir /usr/local/bin

# uv installer
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    ln -sf /root/.local/bin/uv /usr/local/bin/uv

# Switch to moltis user for runtime
USER moltis

# Single persistent volume for all state
VOLUME ["/data"]

# Env vars for persistent volume paths — runtime uses /data for persistence
ENV MOLTIS_CONFIG_DIR=/data/moltis-config
ENV MOLTIS_DATA_DIR=/data/moltis-data
ENV PNPM_HOME=/data/pnpm-store
ENV PNPM_STORE_DIR=/data/pnpm-store/store
ENV UV_CACHE_DIR=/data/uv-cache
ENV UV_TOOL_DIR=/data/uv-tools
ENV UV_LINK_MODE=copy
ENV PATH="/data/pnpm-store/global/bin:/root/.local/bin:/usr/local/bin:${PATH}"

# Cloud deployment env vars — use MOLTIS_* prefix per docs.moltis.org/cloud-deploy.html
ENV MOLTIS_BIND=0.0.0.0
ENV MOLTIS_NO_TLS=true
ENV MOLTIS_PORT=13131
ENV MOLTIS_LOG_LEVEL=info
ENV MOLTIS_DEPLOY_PLATFORM=clawcloud

# Data directories (runtime persistence)

# Disable sandbox and docker (ClawCloud doesn't provide socket)
ENV MOLTIS_SANDBOX_ENABLED=false
ENV MOLTIS_DOCKER_ENABLED=false


# Initial admin password — set via env for automated cloud deployment
# Shows recovery key on first boot; store it securely
ENV MOLTIS_PASSWORD=

# SSH is built into moltis gateway on port 1455
EXPOSE 13131 13132 1455

WORKDIR /home/moltis

ENTRYPOINT ["/init.sh"]
# Port and bind set via env vars, not CLI — per cloud-deploy docs
CMD []