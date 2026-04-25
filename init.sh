#!/bin/sh
set -e

export PNPM_HOME=/data/pnpm-store
export PNPM_STORE_DIR=/data/pnpm-store
export UV_CACHE_DIR=/data/uv-cache
export UV_TOOL_DIR=/data/uv-tools
export QMD_DATA_DIR=/data/qmd-data
export PATH="/data/pnpm-store/global/bin:/data/uv-tools/bin:/root/.local/bin:/usr/local/bin:$PATH"
export SHELL=/bin/bash

# Ensure dirs exist
mkdir -p \
  /data/pnpm-store \
  /data/pnpm-store/global \
  /data/uv-cache \
  /data/uv-tools \
  /data/moltis-config \
  /data/moltis-data \
  /data/qmd-data

# Generate moltis.toml with Zo MCP server config
# ZO_API_TOKEN is injected at container runtime from the env var
cat > /data/moltis-config/moltis.toml << MCPEOF
[mcp]
request_timeout_secs = 30

[mcp.servers.zo]
transport = "sse"
url = "https://api.zo.computer/mcp"

[memory]
backend = "qmd"
provider = "openai"

[memory.qmd]
command = "qmd"
max_results = 10
timeout_ms = 30000
MCPEOF

# Initialize QMD semantic search memory
# Add memory collection and embed if not already done
if [ ! -f /data/qmd-data/.initialized ]; then
    qmd collection add /data/moltis-data --name moltis-memory 2>/dev/null || true
    qmd embed 2>/dev/null || true
    touch /data/qmd-data/.initialized
fi

# Start Moltis
exec moltis --bind 0.0.0.0 --port ${MOLTIS_PORT:-13131}