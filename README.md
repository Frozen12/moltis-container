---

# Moltis Container for ClawCloud

A production-ready Docker image for running **Moltis** on ClawCloud with root access, persistent `/data` volume, and essential tools for autonomous agents.

---

## Ports

| Port  | Protocol | Service                        |
|-------|----------|--------------------------------|
| `13131` | HTTP     | Moltis gateway API             |
| `13132` | WebSocket | Moltis WebSocket connections  |
| `1455`  | SSH      | Moltis built-in SSH server     |

---

## Quick Start

```bash
docker run -d \
  --name moltis \
  -p 13131:13131 \
  -p 13132:13132 \
  -p 1455:1455 \
  -v molt-data:/data \
  -e MOLTIS_GATEWAY_TOKEN=your_token_here \
  -e MOLTIS_LOG_LEVEL=info \
  meshpotato/moltis:latest
```

---

## Environment Variables

| Variable              | Default                           | Description                              |
|-----------------------|-----------------------------------|------------------------------------------|
| `MOLTIS_GATEWAY_TOKEN`| `changeme_set_your_token_here`    | Gateway auth token — **change this**    |
| `MOLTIS_LOG_LEVEL`    | `info`                            | Logging: `error` `warn` `info` `debug` `trace` |
| `MOLTIS_PORT`         | `13131`                           | HTTP gateway port                        |
| `MOLTIS_HOST`         | `0.0.0.0`                         | Bind address                             |
| `MOLTIS_NO_TLS`       | `true`                            | Disable TLS                              |
| `MOLTIS_CONFIG_DIR`   | `/data/moltis-config`             | Gateway config directory                 |
| `MOLTIS_DATA_DIR`     | `/data/moltis-data`               | App data directory                       |
| `MOLTIS_SANDBOX_ENABLED`| `false`                         | Sandboxing (disabled for ClawCloud)      |
| `MOLTIS_DOCKER_ENABLED`| `false`                          | Docker access (disabled for ClawCloud)   |
| `MOLTIS_DEPLOY_PLATFORM`| `clawcloud`                     | Deployment platform hint                 |

---

## Log Levels

| Level   | Use case                                          |
|---------|---------------------------------------------------|
| `error` | Unrecoverable issues only                        |
| `warn`  | Unexpected but recoverable events                |
| `info`  | Normal operational milestones (default)          |
| `debug` | Detailed diagnostics for troubleshooting          |
| `trace` | Very verbose per-item logging                     |

> **Recommended for production:** `info` — keeps logs clean. Use `debug` only when debugging issues.

---

## Volumes

| Path                 | Purpose                              |
|----------------------|--------------------------------------|
| `/data`              | Single persistent volume — contains all below |
| `/data/moltis-config`| Gateway config (moltis.toml)         |
| `/data/moltis-data`  | App data, sessions, database        |
| `/data/pnpm-store`   | pnpm global packages                 |
| `/data/uv-cache`     | uv tool cache                        |

---

## Installed Tools

- **Node.js 24 LTS**
- **pnpm** via corepack
- **uv** Python package manager
- **mcporter** — Zo Computer MCP server CLI
- **curl, jq, ripgrep, fzf, rsync, gh, sudo, tmux, vim, ca-certificates**

---

## Zo Computer MCP Integration

At startup, `init.sh` auto-generates `/data/moltis-config/moltis.toml` with the Zo Computer MCP server configured:

```toml
[mcp]
request_timeout_secs = 30

[mcp.servers.zo]
transport = "sse"
url = "https://api.zo.computer/mcp"
```

Set your Zo API token at runtime:

```bash
docker run -d ... \
  -e ZO_API_TOKEN=your_zo_token_here \
  meshpotato/moltis:latest
```

---

## Build & Push

Every push to `main` triggers GitHub Actions which builds and pushes the image to Docker Hub as `meshtapotato/moltis:latest` (linux/amd64 + linux/arm64).

---

## SSH Access

Moltis has a built-in SSH server on port `1455`. Authenticate with your `MOLTIS_GATEWAY_TOKEN`:

```bash
ssh -p 1455 user@your-host
```

---

## Notes

- Designed for ClawCloud — runs as root, no Docker socket needed
- Sandbox and Docker features disabled by default
- GitHub Actions workflow: `.github/workflows/docker.yml`