#!/bin/sh
set -e

# Runtime env ONLY here
export PNPM_HOME=/data/pnpm
export PNPM_STORE_DIR=/data/pnpm/store
export UV_CACHE_DIR=/data/uv/cache
export UV_TOOL_DIR=/data/uv/tools
export PATH="/data/pnpm:/data/uv/tools:/usr/local/bin:$PATH"

# Ensure dirs exist
mkdir -p \
  /data/pnpm \
  /data/pnpm/store \
  /data/uv/cache \
  /data/uv/tools \
  /data/moltis/config

# Configure pnpm runtime behavior
pnpm config set global-bin-dir /data/pnpm
pnpm config set store-dir /data/pnpm/store
pnpm config set cache-dir /data/pnpm/store

########################################
# 🚀 Install Moltis (only if missing)
########################################
if ! command -v moltis >/dev/null 2>&1; then
  echo "🔽 Installing Moltis..."

  TAG=$(curl -fsSL https://api.github.com/repos/moltis-org/moltis/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
  VERSION=${TAG#v}

  curl -fL "https://github.com/moltis-org/moltis/releases/download/${TAG}/moltis_${VERSION}_amd64.deb" -o /tmp/moltis.deb
  dpkg -i /tmp/moltis.deb || apt-get -f install -y
  rm -f /tmp/moltis.deb

  echo "✅ Moltis installed"
else
  echo "⚡ Moltis already installed, skipping..."
fi

########################################
# 🚀 Start Moltis
########################################
exec moltis --bind 0.0.0.0 --port ${PORT:-13131}
