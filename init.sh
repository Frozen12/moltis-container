#!/bin/sh
set -e

# Fix volume permissions
chown -R moltis:moltis /data 2>/dev/null || true

# Ensure required dirs
mkdir -p /data/moltis/config

# Start qmd
qmd &

# Start main service
exec moltis --bind 0.0.0.0 --port ${PORT:-13131}
