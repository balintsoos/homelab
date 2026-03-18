Self-hosted Docker Compose stack for media automation, smart home, and infrastructure services. The entire stack is defined in a single `compose.yaml` with pre-built images and environment variables sourced from `.env`.

## Conventions

- **Commit messages**: use conventional format like `feat:`, `fix:`, `docs:`, etc.
- **Images**: prefer `ghcr.io/hotio/*` where available; otherwise official images.
- **Environment variables**: all secrets and host-specific values go in `.env` (never committed). Template is `env.template`.
- **Restart policy**: all services use `restart: unless-stopped`.
- **Permissions**: `PUID`/`PGID` env vars align container user with host filesystem ownership.
- **Volume paths**: use `./` relative paths (e.g. `./appdata/`, `./data/`); system mounts like `/var/run/docker.sock` are the only exception.
