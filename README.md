---

# Moltis Container for ClawCloud

A production-ready Docker image for running **Moltis** on ClawCloud with root access and persistent volume support.

---

## ⚠️ IMPORTANT: Set Your Gateway Token

> The default gateway token is a placeholder. **You must set your own token before deploying:**

```bash
-e MOLTIS_GATEWAY_TOKEN=your_secret_token_here
```

---

## 🚀 Quick Start

```bash
docker run -d \
  --name moltis \
  -p 13131:13131 \
  -p 13132:13132 \
  -p 1455:1455 \
  -v moltis-data:/data \
  -e MOLTIS_GATEWAY_TOKEN=your_token_here \
  meshpotato/moltis:latest
```

---

## 📦 Features

* ⚡ Optimized for ClawCloud and low-resource VPS environments
* 🧠 Uses `better-sqlite3` for fast local database access
* 📁 Persistent data via `/data` volume (single volume for all state)
* 🔧 pnpm + uv pre-installed for autonomous agent tooling
* 🚫 Sandbox execution disabled (ClawCloud compatible)
* 🐧 Debian-based multi-stage build

---

## 🐳 Docker Usage

### Build locally

```bash
docker build -t moltis:latest .
```

### Run container

```bash
docker run -d \
  --name moltis \
  -p 13131:13131 \
  -p 13132:13132 \
  -p 1455:1455 \
  -v moltis-data:/data \
  -e MOLTIS_GATEWAY_TOKEN=your_token_here \
  meshpotato/moltis:latest
```

---

## ⚙️ Environment Variables

| Variable              | Default                        | Description                          |
| --------------------- | ------------------------------ | ------------------------------------ |
| `MOLTIS_GATEWAY_TOKEN` | `changeme_set_your_token_here` | ⚠️ Change before deploying          |
| `MOLTIS_PORT`         | `13131`                        | HTTP API port                        |
| `MOLTIS_HOST`         | `0.0.0.0`                      | Bind address                         |
| `MOLTIS_LOG_LEVEL`    | `info`                         | Log verbosity                        |
| `MOLTIS_SANDBOX_ENABLED` | `false`                    | Sandbox disabled for ClawCloud       |
| `MOLTIS_DOCKER_ENABLED`  | `false`                     | Docker CLI disabled                  |
| `SHELL`               | `/bin/bash`                    | Default shell                        |

---

## 📁 Volume Structure

All state lives under a single `/data` volume:

| Path                    | Purpose                          |
| ----------------------- | -------------------------------- |
| `/data/pnpm-store`      | pnpm package store               |
| `/data/uv-cache`        | uv tool cache                    |
| `/data/uv-tools`        | uv installed tools               |
| `/data/moltis-config`   | Gateway configuration            |
| `/data/moltis-data`     | App data (sessions, DB, etc.)    |

---

## 🌐 Ports

| Port  | Service        |
| ------| -------------- |
| 13131 | Moltis HTTP API (Gateway) |
| 13132 | WebSocket              |
| 1455  | SSH                    |

---

## 🧠 Installed Components

* Moltis (latest release, multi-stage build)
* Node.js 22 LTS (via NodeSource)
* pnpm (via corepack)
* uv (official installer)
* Python 3
* Build tools (cmake, build-essential, libclang-dev)
* Docker CLI + buildx (for sandbox-free container operations)

---

## 🔐 Access

After running:

```
http://localhost:13131   # Gateway UI
ssh root@localhost -p 1455   # SSH access
```

---

## 📌 Notes

* Designed for ClawCloud deployment with root access
* Sandbox disabled — agents install packages at runtime via pnpm/uv
* Docker CLI available but sandbox execution disabled
* SQLite used for simplicity and speed
* No GPU / LLM binaries included (external integration expected)