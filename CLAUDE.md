# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Self-hosted Docker Compose stack for media automation, smart home, and infrastructure services. The entire stack is defined in a single `docker-compose.yml` with environment variables sourced from `.env`.

## Commands

```bash
make setup          # Full first-time setup (check docker, create dirs, copy defaults, create .env)
make up             # Start all services (docker compose up -d)
make down           # Stop all services
make restart        # Restart all services
make logs           # Tail logs from all services
make ps             # Show service status
make backup         # Stop services, create timestamped tar.gz of appdata + config, optionally sync via rclone, restart
make restore BACKUP_FILE=/path/to/archive.tar.gz  # Restore from backup archive
```

## Architecture

**Single compose file** (`docker-compose.yml`) defines all ~16 services. No build step — all services use pre-built images.

**Network segmentation** — four isolated Docker networks:
- `proxy` — services exposed through Nginx Proxy Manager
- `media` — Arr stack (Radarr, Sonarr, Prowlarr), qBittorrent, Jellyfin, Seerr
- `iot` — Zigbee2MQTT, Mosquitto (MQTT broker), Home Assistant
- `monitoring` — Beszel hub/agent

**Security pattern**: Admin web UIs are bound to `127.0.0.1` (localhost only) and accessed through the reverse proxy (Nginx Proxy Manager) or SSH tunnel. Only public-facing ports (Jellyfin 8096, WireGuard 51820/udp, HTTP/HTTPS 80/443, DNS 53, MQTT 1883/9001) are exposed to the LAN.

**Host paths**:
- `/docker/appdata/{service}/` — persistent config/data per service
- `/data/media/{movies,tv}` — media library
- `/data/torrents/{movies,tv}` — download staging

**Configuration defaults** live in `defaults/` and are copied to `/docker/appdata/` on first setup (`cp -rn`, non-destructive).

## Conventions

- **Commit messages**: conventional format — `feat:`, `fix:`, `docs:`, etc.
- **Images**: prefer `ghcr.io/hotio/*` where available; otherwise official images.
- **Environment variables**: all secrets and host-specific values go in `.env` (never committed). Template is `env.template`.
- **Restart policy**: all services use `restart: unless-stopped`.
- **Permissions**: `PUID`/`PGID` env vars align container user with host filesystem ownership.
