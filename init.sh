#!/bin/sh
set -e

# Fix permissions (for mounted volumes)
chown -R moltis:moltis /data 2>/dev/null || true

# Ensure required directories exist
mkdir -p /data/moltis/config

# Start qmd in background
qmd &

# Start moltis (main process)
exec moltis --bind 0.0.0.0 --port ${PORT:-13131}
