# Moltis for ClawCloud — root user, single /data volume
FROM ghcr.io/moltis-org/moltis:latest

ENV DEBIAN_FRONTEND=noninteractive

# All package installation runs as root
USER root

RUN apt-get update -qq && \
    apt-get install -yqq --no-install-recommends \
        jq ripgrep fzf rsync gh duf python3 tmux && \
    rm -rf /var/lib/apt/lists/*

# Node.js 24 LTS — download official binary tarball directly
RUN curl -fsSL https://nodejs.org/dist/v24.0.0/node-v24.0.0-linux-x64.tar.gz \
    | tar -xz -C /usr/local --strip-components=1 && \
    ln -sf /usr/local/bin/node /usr/local/bin/nodejs


# Single persistent volume for all state
VOLUME ["/data"]
WORKDIR /data

# Env vars for persistent volume paths — runtime uses /data for persistence
ENV MOLTIS_CONFIG_DIR=/data/moltis-config
ENV MOLTIS_DATA_DIR=/data/moltis-data
ENV NPM_CONFIG_PREFIX=/data/npm
ENV UV_CACHE_DIR=/data/uv-cache
ENV UV_TOOL_DIR=/data/uv-tools
ENV UV_LINK_MODE=copy
ENV PATH="/root/.local/bin:/usr/local/bin:${PATH}"

# uv installer
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    ln -sf /root/.local/bin/uv /usr/local/bin/uv
    
# Cloud deployment env vars — use MOLTIS_* prefix per docs.moltis.org/cloud-deploy.html
ENV MOLTIS_BIND=0.0.0.0
ENV MOLTIS_NO_TLS=true
ENV MOLTIS_DEPLOY_PLATFORM=clawcloud

# Disable sandbox and docker (ClawCloud doesn't provide socket)
ENV MOLTIS_SANDBOX_ENABLED=false
ENV MOLTIS_DOCKER_ENABLED=false
ENV MOLTIS_PASSWORD=Change_your_Password_Before_Use

EXPOSE 13131 13132 1455

COPY init.sh /init.sh
RUN chmod +x /init.sh

ENTRYPOINT ["/init.sh"]
# Port and bind set via env vars, not CLI — per cloud-deploy docs
CMD []
