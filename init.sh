#!/bin/sh
set -e

# Fix volume permissions (root phase)
chown -R 10001:10001 /data 2>/dev/null || true

# Ensure required dirs
mkdir -p /data/moltis/config

# Run everything as non-root (clean exec)
exec gosu moltis sh -c '
  qmd &
  exec moltis --bind 0.0.0.0 --port ${PORT:-13131}
'
