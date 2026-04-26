---

# Moltis Container for ClawCloud

A production-ready Docker image for running **Moltis** on ClawCloud with root access, persistent `/data` volume, and essential tools for autonomous agents.

---

## Ports

| Port  | Service                        |
|-------|----------|--------------------------------|
| `13131` | Gateway (HTTPS) — web UI, API, WebSocket           |
| `13132` | HTTP — CA certificate download for TLS trust |
| `1455`  | OAuth callback — required for OpenAI Codex and other providers with pre-registered redirect URIs    |

---

## Environment Variables

| Variable              | Default                           | Description                              |
|-----------------------|-----------------------------------|------------------------------------------|
| `MOLTIS_PASSWORD`    | `changeme_set_your_password_here`     | Gateway admin password — **change this**    |
| `MOLTIS_NO_TLS`       | `true`                            | Disable TLS                              |
| `MOLTIS_CONFIG_DIR`   | `/data/moltis-config`             | Gateway config directory                 |
| `MOLTIS_DATA_DIR`     | `/data/moltis-data`               | App data directory                       |
| `MOLTIS_SANDBOX_ENABLED`| `false`                         | Sandboxing (disabled for ClawCloud)      |
| `MOLTIS_DOCKER_ENABLED`| `false`                          | Docker access (disabled for ClawCloud)   |
| `MOLTIS_DEPLOY_PLATFORM`| `clawcloud`                     | Deployment platform hint                 |

---


## Volume - /data

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
- **uv** Python package manager
- **curl, jq, ripgrep, fzf, rsync, gh, sudo, tmux, vim, ca-certificates**

---


## Build & Push

Every push to `main` triggers GitHub Actions which builds and pushes the image to Docker Hub as `meshtapotato/moltis:latest` (linux/amd64 + linux/arm64).

---

## Notes

- Designed for ClawCloud — runs as root, no Docker socket needed
- Sandbox and Docker features disabled by default
- GitHub Actions workflow: `.github/workflows/docker.yml`
