#!/bin/sh
set -e

# =========================
# Moltis cloud env
# =========================
export MOLTIS_BIND=0.0.0.0
export MOLTIS_NO_TLS=true
export MOLTIS_DEPLOY_PLATFORM=clawcloud

# Disable unsupported features (ClawCloud)
export MOLTIS_SANDBOX_ENABLED=false
export MOLTIS_DOCKER_ENABLED=false

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
# temp (fix npx 100MB issue)
# =========================
export TMPDIR=/tmp

# =========================
# PATH (priority order)
# =========================
export PATH="/data/npm/bin:/data/uv-tools/bin:/usr/local/bin:$PATH"

# Erase $TMPDIR
rm -rf $TMPDIR

# Ensure all persistent dirs exist
mkdir -p \
  /tmp \
  /data/npm \
  /data/npm-cache \
  /data/uv-cache \
  /data/uv-tools \
  /data/moltis-config \
  /data/moltis-data

# Start Moltis
exec moltis --bind 0.0.0.0 --port 13131
