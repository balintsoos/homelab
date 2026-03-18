# Improvement Ideas

## Security

### Container Hardening

- **Read-only root filesystems** — add `read_only: true` to containers that don't need to write outside their volumes (cloudflare-ddns, watchtower, beszel-agent). Combine with `tmpfs` mounts for `/tmp` and `/run` where needed.
- **`no-new-privileges`** — currently only cloudflare-ddns sets `security_opt: no-new-privileges:true`. Apply this to every service to prevent privilege escalation inside containers.
- **Drop all capabilities by default** — add `cap_drop: [ALL]` to every service and only `cap_add` what's actually needed. Right now only wg-easy declares capabilities; the rest run with Docker's default set which is more than necessary.
- **Pin image digests** — `:latest` tags are mutable. Pin images to SHA256 digests (e.g. `image: ghcr.io/hotio/radarr@sha256:abc...`) for reproducibility. Watchtower can still check for updates but you control when to roll forward.
- **Non-root users everywhere** — zigbee2mqtt, mosquitto, and homeassistant use `user:` but the rest rely on PUID/PGID env vars (Hotio convention). Verify each image actually drops to that UID; consider adding explicit `user:` directives where possible.
- **Limit container resources** — add `mem_limit` and `cpus` to prevent a single runaway container (e.g. Jellyfin transcoding) from starving the host. Even soft limits (`mem_reservation`) help the scheduler.

### Secrets Management

- **Docker secrets** — move sensitive `.env` values (API tokens, password hashes, SSH keys) into Docker secrets. Compose supports `secrets:` with file-based secrets, avoiding env vars that leak into `docker inspect` and process listings.
- **Encrypt backups** — the backup archive contains `.env` with all secrets in plaintext. Pipe through `age` or `gpg` before writing (e.g. `tar -czf - ... | age -r <pubkey> > backup.age`). Store the key separately from the backup destination.

### Network Security

- **Mosquitto authentication** — the default config has `allow_anonymous true` and listens on port 1883 without TLS. Add username/password auth at minimum; enable TLS for the listener if devices support it.
- **Restrict MQTT port binding** — port 1883 and 9001 are bound to `0.0.0.0`, exposing MQTT to the entire network. Bind to `127.0.0.1` if only local containers need it, or restrict to the LAN interface.
- **Watchtower Docker socket** — watchtower mounts the Docker socket read-write, which gives it full root-equivalent access to the host. Mount it `:ro` if the image supports it, or use a socket proxy like Tecnativa/docker-socket-proxy to limit API access.
- **Beszel-agent Docker socket** — already mounted `:ro` (good), but consider using a socket proxy here too to restrict to only the monitoring endpoints it needs.

## Networking

### Network Segmentation

- **Restrict cross-network access** — services are on named networks (proxy, media, iot, monitoring) but there's no `internal: true` on any of them. Mark `media`, `iot`, and `monitoring` as `internal: true` so containers on those networks can't reach the internet directly. Only the `proxy` network should have outbound access.
- **Separate download network** — qbittorrent should ideally sit on its own network (or route through the VPN) to isolate torrent traffic from the rest of the media stack.
- **Remove unnecessary network memberships** — mosquitto and zigbee2mqtt are on the `proxy` network but probably only need `iot`. Review each service and strip memberships to the minimum required.

### DNS & Routing

- **Split-horizon DNS** — configure AdGuard Home with DNS rewrites so internal services (e.g. `sonarr.home.yourdomain.com`) resolve to the local LAN IP instead of going through hairpin NAT via the public IP.
- **AdGuard `network_mode: host` conflict** — AdGuard uses `network_mode: host` but also declares `ports:`. With host networking the ports block is ignored. Remove the `ports:` block for clarity, or switch to bridge mode and explicitly expose only 53 and the web UI port.

### VPN Integration

- **Route qbittorrent through WireGuard** — use `network_mode: "service:wg-easy"` or a dedicated VPN container (like gluetun) to force all torrent traffic through the VPN tunnel, preventing IP leaks.

## Docker Best Practices

### Image Management

- **Use Watchtower's official image** — currently using `nickfedor/watchtower:latest` which is a third-party fork. Switch to the official `containrrr/watchtower:latest` unless there's a specific reason for the fork.
- **Watchtower missing restart policy** — watchtower and cloudflare-ddns are missing `restart: unless-stopped`. Add it for consistency.
- **Watchtower missing network** — watchtower has no network assignment, which puts it on the default bridge. This is fine functionally but inconsistent with the rest of the stack.

### Health Checks

- Add `healthcheck:` directives so Docker can detect and restart unresponsive containers:
  - **Jellyfin**: `curl -f http://localhost:8096/health || exit 1`
  - **Radarr/Sonarr/Prowlarr**: `curl -f http://localhost:<port>/ping || exit 1`
  - **qBittorrent**: `curl -f http://localhost:8080/api/v2/app/version || exit 1`
  - **AdGuard Home**: `curl -f http://localhost:3000 || exit 1`
  - **MQTT**: `mosquitto_sub -t '$SYS/broker/uptime' -C 1 -W 5 || exit 1`
  - **Nginx Proxy Manager**: `curl -f http://localhost:81/api || exit 1`
  - **Home Assistant**: `curl -f http://localhost:8123/api/ || exit 1`

### Compose File Improvements

- **`depends_on` with health conditions** — add `depends_on:` to enforce startup order: zigbee2mqtt depends on mosquitto, sonarr/radarr depend on prowlarr, seerr depends on sonarr+radarr. Use `condition: service_healthy` once health checks are in place.
- **Logging configuration** — add `logging:` with `driver: json-file` and `max-size`/`max-file` options to prevent unbounded log growth on disk. e.g. `max-size: "10m"`, `max-file: "3"`.
- **Labels** — add labels for organization and tooling (e.g. `com.homelab.group=media`) which can be used by monitoring dashboards, Watchtower filters, and backup scripts.

## Monitoring & Observability

- **Uptime Kuma** — lightweight status page and uptime monitor with push/pull checks and multi-channel notifications (Telegram, Discord, email, Slack). Pair with health check endpoints from each service.
- **Log aggregation** — add Dozzle for a lightweight real-time log viewer, or Loki + Grafana for persistent searchable logs. Dozzle is zero-config; Loki requires more setup but enables alerting on log patterns.
- **Grafana dashboards** — Beszel handles system metrics, but Grafana could pull data from AdGuard (DNS stats), Home Assistant (sensor history), and qBittorrent (download stats) for a unified view.
- **Container update notifications** — configure Watchtower to notify-only mode (`WATCHTOWER_NOTIFICATIONS`) so you review updates before they're applied, rather than auto-updating everything at 4am.

## Automation & DX

- **`make update` target** — pull latest images and recreate only changed containers: `docker compose pull && docker compose up -d --remove-orphans`.
- **`make backup` without downtime** — the current backup stops all services. For most containers you can safely tar the appdata while running (Jellyfin, Radarr, etc. use SQLite with WAL mode). Only stop services whose data can't be copied live.
- **Scheduled backups** — add a cron job or systemd timer to run `make backup` automatically (e.g. weekly). The Makefile already has the logic; it just needs scheduling.
- **Pre-commit validation** — add a git pre-commit hook or CI check that runs `docker compose config -q` and `dclint` to catch compose syntax errors before they're committed.
- **`.env` validation** — add a `make check-env` target that verifies all required variables in `env.template` are defined in `.env` and non-empty, catching misconfigurations before `docker compose up`.

## New Services

- **Homepage / Homarr** — dashboard/landing page that auto-discovers Docker containers and displays service status, bookmarks, and widget integrations (Sonarr queue, Radarr calendar, qBit speeds, AdGuard stats).
- **Authelia / Authentik** — SSO and 2FA gateway for all services behind Nginx Proxy Manager. Protects services that lack built-in authentication (Dozzle, Beszel, Zigbee2MQTT web UI).
- **Gluetun** — VPN client container that qbittorrent (and other services) can route through via `network_mode: "service:gluetun"`. Supports WireGuard/OpenVPN with built-in kill switch and port forwarding.
- **Crowdsec or Fail2ban** — intrusion prevention that parses Nginx Proxy Manager logs and bans IPs after repeated failed auth attempts or suspicious patterns.
- **Recyclarr** — automatically sync TRaSH Guides quality profiles to Radarr and Sonarr, keeping release scoring and custom formats up to date without manual config.
- **Flaresolverr** — proxy server for Prowlarr to bypass Cloudflare protection on indexer sites.
- **Tdarr / Unmanic** — automated media transcoding to optimize library storage (e.g. HEVC conversion) while Jellyfin handles on-the-fly transcoding for playback.
