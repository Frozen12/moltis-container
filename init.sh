#!/bin/sh
set -e

# Ensure all persistent dirs exist
mkdir -p \
  /data/tmp \
  /data/npm \
  /data/npm-cache \
  /data/uv-cache \
  /data/uv-tools \
  /data/moltis-config \
  /data/moltis-data


# =========================
# Moltis cloud env
# =========================
export MOLTIS_NO_TLS=true
export MOLTIS_DEPLOY_PLATFORM=clawcloud

# Moltis core Environment Variables
export MOLTIS_SERVER__BIND=0.0.0.0
export MOLTIS_SERVER__PORT=13131
export MOLTIS_CONFIG_DIR=/data/moltis-config
export MOLTIS_DATA_DIR=/data/moltis-data

# Generate password only if MOLTIS_PASSWORD is empty or unset
# If empty → generate and log it
if [ -z "${MOLTIS_PASSWORD}" ]; then
  export MOLTIS_PASSWORD="$(openssl rand -base64 16)"
  echo "[MOLTIS] Generated password: ${MOLTIS_PASSWORD}"
fi

# =========================
# npm / npx setup
# =========================
export NPM_CONFIG_PREFIX=/data/npm
export npm_config_cache=/data/npm-cache

# =========================
# uv (Python tools)
# =========================
export UV_CACHE_DIR=/data/uv-cache
export UV_TOOL_DIR=/data/uv-tools

# =========================
# temp (fix npx runtime 100MB limit issue)
# =========================
# Erase /data/tmp/ contents
rm -rf /data/tmp/*
# set tmpt directory
export TMPDIR=/data/tmp

# =========================
# PATH (priority order)
# =========================
export PATH="/data/npm/bin:/data/uv-tools/bin:/usr/local/bin:$PATH"

# Start Moltis
exec moltis
