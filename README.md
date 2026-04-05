---

# 🚀 Moltis Container (Minimal & Optimized)

A lightweight, production-ready Docker setup for running **Moltis** on low-resource environments.

---

## ⚠️ IMPORTANT: Change Default Password

> 🚨 **The default password is `admin` — this is NOT secure.**

You **must change it before deploying publicly**:

```bash
-e MOLTIS_PASSWORD=your_strong_password_here
```

Example:

```bash
docker run -d \
  --name moltis \
  -p 13131:13131 \
  -v moltis-data:/data \
  -e PORT=13131 \
  -e MOLTIS_PASSWORD=MySecurePass123! \
  moltis:latest
```

---

## 📦 Features

* ⚡ Optimized for low-resource environments (cloud/VPS)
* 🧠 Uses `better-sqlite3` for fast local database access
* 🔁 Persistent data via `/data` volume
* 🚫 TLS disabled (intended for external handling if needed)
* 🐧 Alpine-based minimal image

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
  -v moltis-data:/data \
  -e PORT=13131 \
  -e MOLTIS_PASSWORD=your_password_here \
  moltis:latest
```

---

## ⚙️ Environment Variables

| Variable                 | Default        | Description                           |
| ------------------------ | -------------- | ------------------------------------- |
| `MOLTIS_PASSWORD`        | `admin`        | ⚠️ Change this immediately            |
| `MOLTIS_DATA_DIR`        | `/data`        | Data directory                        |
| `MOLTIS_CONFIG_DIR`      | `/data/config` | Config directory                      |
| `MOLTIS_NO_TLS`          | `true`         | Disable TLS                           |
| `MOLTIS_DEPLOY_PLATFORM` | `vultr`        | Deployment hint (your cloud provider) |
| `PORT`                   | `13131`        | Application port                      |

---

## 📁 Volumes

| Path    | Purpose                                    |
| ------- | ------------------------------------------ |
| `/data` | Stores configs, database, and runtime data |

---

## 🧠 Installed Components

* Node.js (LTS, Alpine)
* pnpm (via corepack)
* Python (venv at `/data/venv`)
* Moltis
* `better-sqlite3`
* `@tobilu/qmd`

---

## 🌐 Access

After running:

```
http://localhost:13131
```

---

## 📌 Notes

* Designed for cloud deployment 
* No GPU / LLM binaries included (external integration expected)
* SQLite used for simplicity and speed
* Chomium not included

---
