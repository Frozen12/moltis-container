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


# uv installer
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    ln -sf /root/.local/bin/uv /usr/local/bin/uv

EXPOSE 13131 13132 1455

COPY init.sh /init.sh
RUN chmod +x /init.sh

ENTRYPOINT ["/init.sh"]

CMD []
