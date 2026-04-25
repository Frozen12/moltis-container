# Moltis for ClawCloud — root user, single /data volume
# Base: official moltis image with essential tools added

FROM ghcr.io/moltis-org/moltis:latest

ENV DEBIAN_FRONTEND=noninteractive

# Switch to root for package installation (base image ends with USER moltis)
USER root

# Essential tools for autonomous agent (no bloat)
# Removed: curl,ca-certificates (in base), sudo (root), ncdu (dup of duf)
RUN apt-get update -qq && \
    apt-get install -yqq --no-install-recommends \
        jq ripgrep fzf rsync gh duf python3 tmux && \
    rm -rf /var/lib/apt/lists/*

# Node.js 24 LTS
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" \
    > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update -qq && \
    apt-get install -yqq --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# pnpm via corepack
RUN corepack enable && corepack prepare pnpm@latest --activate

# uv installer
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    ln -sf /root/.local/bin/uv /usr/local/bin/uv

# QMD — semantic search sidecar for moltis memory
RUN npm install -g @tobilu/qmd

# mcporter — Zo Computer MCP server CLI (via pnpm)
RUN pnpm add -g mcporter

# Switch back to moltis user for runtime
USER moltis

# Single persistent volume for all state
VOLUME ["/data"]

# Env vars for persistent volume paths
ENV MOLTIS_CONFIG_DIR=/data/moltis-config
ENV MOLTIS_DATA_DIR=/data/moltis-data
ENV PNPM_HOME=/data/pnpm-store
ENV PNPM_STORE_DIR=/data/pnpm-store/store
ENV UV_CACHE_DIR=/data/uv-cache
ENV UV_TOOL_DIR=/data/uv-tools
ENV UV_LINK_MODE=copy
ENV QMD_DATA_DIR=/data/qmd-data
ENV PATH="/data/pnpm-store/global/bin:/root/.local/bin:/usr/local/bin:${PATH}"

# Disable sandbox and docker (ClawCloud doesn't provide socket)
ENV MOLTIS_SANDBOX_ENABLED=false
ENV MOLTIS_DOCKER_ENABLED=false

# Gateway token — user replaces this before deploy
ENV MOLTIS_GATEWAY_TOKEN=changeme_set_your_token_here

# Port config (moltis default)
ENV MOLTIS_PORT=13131
ENV MOLTIS_HOST=0.0.0.0
ENV MOLTIS_LOG_LEVEL=info

# SSH is built into moltis gateway on port 1455
EXPOSE 13131 13132 1455

WORKDIR /home/moltis

# Run init.sh first (sets up dirs + moltis.toml), then exec into moltis
ENTRYPOINT ["/bin/sh", "/init.sh"]
CMD ["--bind", "0.0.0.0", "--port", "13131"]