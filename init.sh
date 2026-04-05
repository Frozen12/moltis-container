#!/bin/sh
set -e

# Fix volume permissions (must run as root)
chown -R 10001:10001 /data 2>/dev/null || true

# Ensure required dirs
mkdir -p /data/moltis/config

# Drop to non-root and run services
exec su moltis -c "
  qmd &
  exec moltis --bind 0.0.0.0 --port ${PORT:-13131}
"
