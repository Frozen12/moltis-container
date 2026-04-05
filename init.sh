#!/bin/sh
set -e

mkdir -p /data/moltis/config

# Start qmd
qmd &

# Start Moltis
exec moltis --bind 0.0.0.0 --port ${PORT:-13131}
