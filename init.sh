#!/bin/sh
set -e

export PNPM_HOME=/data/pnpm-store
export PNPM_STORE_DIR=/data/pnpm-store
export UV_CACHE_DIR=/data/uv-cache
export UV_TOOL_DIR=/data/uv-tools
export PATH="/data/pnpm-store/global/bin:/data/uv-tools/bin:/usr/local/bin:$PATH"
export SHELL=/bin/bash

# Ensure dirs exist
mkdir -p \
  /data/pnpm-store \
  /data/pnpm-store/global \
  /data/uv-cache \
  /data/uv-tools \
  /data/moltis-config \
  /data/moltis-data

# Generate moltis.toml with Zo MCP server config
# ZO_API_TOKEN is injected at container runtime from the env var
cat > /data/moltis-config/moltis.toml << MCPEOF
[mcp]
request_timeout_secs = 30

[mcp.servers.zo]
transport = "sse"
url = "https://api.zo.computer/mcp"
MCPEOF

# Start Moltis
exec moltis --bind 0.0.0.0 --port ${MOLTIS_PORT:-13131}
