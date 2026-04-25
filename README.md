---

# Moltis Container for ClawCloud

A production-ready Docker image for running **Moltis** on ClawCloud with root access, persistent volume, and Zo Computer MCP integration.

---

## ⚠️ IMPORTANT: Set Your Gateway Token

> The default gateway token is `changeme` — you **must** replace it before deploying publicly.

**Required env var to set in ClawCloud:**
```bash
MOLTIS_GATEWAY_TOKEN=your_actual_token_here
```

---

## 🔗 Zo Computer MCP Integration

Moltis connects to your Zo Computer workspace via the MCP (Model Context Protocol) over SSE. Configure with these env vars:

| Variable | Description |
|---|---|
| `MOLTIS_ZO_API_TOKEN` | Your Zo Computer API token for MCP auth |
| `MOLTIS_GATEWAY_TOKEN` | Moltis gateway password |

The `moltis.toml` is auto-generated at startup with the Zo MCP server endpoint (`https://api.zo.computer/mcp`). If `MOLTIS_ZO_API_TOKEN` is set, it's injected as a bearer token in the Authorization header.

---

## 📦 Features

- **Root access** — runs as root, persistent volume fully accessible
- **Single `/data` volume** — all state (config, data, pnpm, uv) in one place
- **pnpm + uv pre-installed** — autonomous agents can install packages instantly
- **Zo MCP ready** — connects to Zo Computer out of the box
- **Debug logging** — `MOLTIS_LOG_LEVEL=debug` enabled for troubleshooting
- **SSH built-in** — port 1455 (moltis gateway SSH)
- **No Docker socket needed** — sandbox and Docker exec disabled

---

## 🐳 Ports

| Port | Service |
|---|---|
| `13131` | Moltis gateway (HTTP API) |
| `13132` | WebSocket |
| `1455` | SSH |

---

## 📁 Volume

Single persistent volume at `/data/` with subdirs:

| Path | Purpose |
|---|---|
| `/data/moltis-config` | Gateway config + moltis.toml |
| `/data/moltis-data` | App data (sessions, etc.) |
| `/data/pnpm-store` | pnpm global store |
| `/data/uv-cache` | uv pip cache |

---

## 🔧 Environment Variables

| Variable | Default | Description |
|---|---|---|
| `MOLTIS_GATEWAY_TOKEN` | `changeme` | ⚠️ Change before deploy |
| `MOLTIS_ZO_API_TOKEN` | — | Zo Computer API token for MCP auth |
| `MOLTIS_PORT` | `13131` | Gateway port |
| `MOLTIS_HOST` | `0.0.0.0` | Bind address |
| `MOLTIS_LOG_LEVEL` | `debug` | Log verbosity |
| `MOLTIS_SANDBOX_ENABLED` | `false` | Sandboxing (disabled for ClawCloud) |
| `MOLTIS_DOCKER_ENABLED` | `false` | Docker exec (disabled) |
| `PNPM_HOME` | `/data/pnpm-store` | pnpm data dir |
| `UV_CACHE_DIR` | `/data/uv-cache` | uv cache dir |

---

## 🚀 Deploy on ClawCloud

1. Push to GitHub — GitHub Actions builds and pushes to Docker Hub as `meshtapotato/moltis:latest`
2. In ClawCloud, create a service with:
   - Image: `meshtapotato/moltis:latest`
   - Persistent volume: `/data`
   - Env vars: `MOLTIS_GATEWAY_TOKEN`, `MOLTIS_ZO_API_TOKEN`
   - Ports: `13131`, `13132`, `1455`

---

## 🌐 Access

After deployment:
```
http://your-clawcloud-host:13131
SSH: your-clawcloud-host:1455
```

---

## 🛠️ Extra Packages Installed

`poppler-utils unoconv html2text w3m jq ripgrep fzf rsync gh ncdu duf python3 pip mcporter`

Designed for autonomous agent workflows — no human-centric tools included.
