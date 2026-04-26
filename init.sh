#!/bin/sh
set -e

export NPM_CONFIG_PREFIX=/data/npm
export PNPM_HOME=/data/pnpm-store
export PNPM_STORE_DIR=/data/pnpm-store
export UV_CACHE_DIR=/data/uv-cache
export UV_TOOL_DIR=/data/uv-tools
export PATH="/data/pnpm-store/global/bin:/data/uv-tools/bin:/usr/local/bin:$PATH"
export SHELL=/bin/bash

# Ensure all persistent dirs exist
mkdir -p \
  /data/npm \
  /data/pnpm-store \
  /data/pnpm-store/global \
  /data/uv-cache \
  /data/uv-tools \
  /data/moltis-config \
  /data/moltis-data

# 🔥 SAFE PORT HANDLING
PORT="${MOLTIS_PORT:-13131}"

case "$PORT" in
  tcp://*)
    PORT="${PORT##*:}"
    ;;
esac

# Start Moltis
exec moltis --bind 0.0.0.0 --port $PORT
