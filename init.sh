#!/bin/sh
set -e

# Ensure required dirs
mkdir -p /data/moltis/config

# Start qmd
qmd &

# Start main service
exec moltis --bind 0.0.0.0 --port ${PORT:-13131}
