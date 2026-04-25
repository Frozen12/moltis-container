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
# This enables moltis to connect to Zo Computer via MCP over SSE
cat > /data/moltis-config/moltis.toml << 'MCPEOF'
[mcp]
request_timeout_secs = 30

[mcp.servers.zo]
transport = "sse"
url = "https://api.zo.computer/mcp"
MCPEOF

# Wait for moltis to be ready
echo "Waiting for moltis to start..."
for i in $(seq 1 30); do
  if curl -sf http://localhost:${MOLTIS_PORT:-13131}/health > /dev/null 2>&1; then
    echo "Moltis is ready"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 2
done

# Start moltis
exec moltis --bind 0.0.0.0 --port ${MOLTIS_PORT:-13131}
