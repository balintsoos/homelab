# Improvement Ideas

## Reliability & Security

- Encrypt backups (GPG or age) so secrets in `.env` aren't stored in plaintext archives
- Backup retention policy — automatically prune old local backups (e.g., keep last 7)
- Health checks in `compose.yaml` so Docker can auto-restart unhealthy containers
- Secrets management — move sensitive values out of `.env` into Docker secrets or a vault

## Networking & Access

- Tailscale or Headscale as a WireGuard alternative with easier device onboarding
- Fail2ban or CrowdSec for intrusion detection on exposed services
- Traefik as an alternative to Nginx Proxy Manager with config-as-code (no UI state to lose)
- Split DNS so internal services resolve to LAN IPs without hairpin NAT

## Monitoring & Alerting

- Uptime Kuma for service health monitoring with notifications (Telegram, Discord, email)
- Disk space alerts — notify before storage fills up
- Log aggregation with Loki + Grafana or Dozzle for centralized container logs

## Automation & DX

- Scheduled backups via cron or a systemd timer instead of manual `make backup`
- `make update` target to pull latest images and recreate changed containers (complementing Watchtower)

## New Services

- Homepage or Flame as a dashboard/landing page for all services
- Authelia or Authentik for SSO across services behind the reverse proxy
- Paperless-ngx for document management
- Immich for self-hosted photo backup (Google Photos alternative)
