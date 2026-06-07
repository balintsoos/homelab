Self-hosted Docker Compose stack for media automation, smart home, and infrastructure services. The stack lives in a small root `compose.yaml` that uses Compose's `include:` directive to pull in per-profile module files under `compose/` (`media.yaml`, `network.yaml`, `vpn.yaml`, `monitoring.yaml`, `iot.yaml`). Pre-built images are used throughout and environment variables are sourced from `.env`. See `README.md` for architecture details (networks, profiles, port binding, data layout) and `IDEAS.md` for the enhancement backlog.

## Conventions

- **Commit messages**: use conventional format like `feat:`, `fix:`, `docs:`, etc.
- **Images**: prefer `ghcr.io/hotio/*` where available; otherwise official images.
- **Environment variables**: all secrets and host-specific values go in `.env` (never committed). Template is `env.template`.
- **Restart policy**: all services use `restart: unless-stopped`.
- **Permissions**: `PUID`/`PGID` env vars align container user with host filesystem ownership.
- **Volume paths**: use `./` relative paths (e.g. `./appdata/`, `./data/`); system mounts like `/var/run/docker.sock` are the only exception.
- **Container naming**: `container_name` matches the service key, lowercase with hyphens. Multi-component services use a suffix (e.g. `beszel-hub`, `beszel-agent`).
- **Profiles**: every service must belong to a relevant profile (`media`, `network`, `vpn`, `monitoring`, `iot`) plus the `all` meta-profile.
- **Port binding**: admin/internal UIs bind to `127.0.0.1`; only public/LAN-facing services bind to `0.0.0.0`.
- **Service ordering**: each profile lives in its own module file under `compose/<profile>.yaml`. New services go at the end of the matching module file.
- **Environment variable ordering**: `PUID`, `PGID`, `TZ` come first; service-specific vars follow.
- **Config templates**: reusable defaults live in `defaults/` and are copied non-destructively by `make setup`. New services needing initial config should add a template there.
- **Automation**: extend the `Makefile` rather than adding standalone scripts (`make setup`, `make lint`, `make backup`, `make restore`).
- **Networks declaration**: each module declares the networks its services attach to at the bottom (just the name, no extra config). The shared `proxy` network is redeclared in every module that uses it; profile-scoped networks (`media`, `iot`, `monitoring`) live only in their owning module. Compose merges same-named networks across included files.

## Adding a new service checklist

1. Add the service to the matching `compose/<profile>.yaml` module (or create a new module file and register it in the root `compose.yaml`'s `include:` list). Use the template below.
2. Add any new secrets/config variables to `env.template` with a commented section and setup instructions.
3. Add the `appdata/` subdirectory to the `setup-dirs` target in `Makefile`.

## New service template

Follow this field order when adding a service to a `compose/<profile>.yaml` module:

```yaml
  service-name:
    image: ghcr.io/hotio/example:latest
    container_name: service-name
    # user: "${PUID}:${PGID}"          # only when image doesn't support PUID/PGID env vars
    # security_opt:
    #   - no-new-privileges:true
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ./appdata/service-name:/config
    ports:
      - "127.0.0.1:PORT:PORT"
    # cap_add:
    # sysctls:
    # devices:
    # group_add:
    # network_mode:                     # use instead of networks when needed (e.g. host)
    networks:
      - proxy
    profiles:
      - <profile>
      - all
    restart: unless-stopped
```
