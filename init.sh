#!/bin/sh
set -e

# Runtime env ONLY here
export PNPM_HOME=/data/pnpm
export PNPM_STORE_DIR=/data/pnpm/store
export UV_CACHE_DIR=/data/uv/cache
export UV_TOOL_DIR=/data/uv/tools
export PATH="/data/pnpm:/data/uv/tools:/usr/local/bin:$PATH"
export SHELL=/bin/bash
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

# (optional but nice)
pnpm config set cache-dir /data/pnpm/store

# pnpm setup
pnpm setup
. /root/.bashrc
# Start qmd
# qmd &

# Start Moltis
exec moltis --bind 0.0.0.0 --port ${PORT:-13131}
