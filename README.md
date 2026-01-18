# homelab

Containerized home server stack with media management, VPN, DNS filtering, reverse proxy, automated updates, and Cloudflare DDNS.

## Services

- [Jellyfin](https://jellyfin.org/) - Media server
- [Radarr](https://radarr.video/) - Movie automation
- [Sonarr](https://sonarr.tv/) - TV automation
- [Prowlarr](https://prowlarr.com/) - Indexer management
- [qBittorrent](https://www.qbittorrent.org/) - BitTorrent client
- [Jellyseerr](https://github.com/Fallenbagel/jellyseerr) - Media requests
- [Homarr](https://homarr.dev/) - Dashboard
- [WireGuard Easy](https://github.com/wg-easy/wg-easy) - WireGuard VPN + UI
- [Watchtower](https://containrrr.dev/watchtower/) - Automated updates
- [Beszel](https://beszel.dev/) - Monitoring
- [AdGuard Home](https://adguard.com/en/adguard-home/overview.html) - DNS filtering
- [Nginx Proxy Manager](https://nginxproxymanager.com/) - Reverse proxy + SSL
- [Cloudflare DDNS](https://github.com/timothymiller/cloudflare-ddns) - Keeps DNS A record updated

## Requirements

- Docker Engine
- A host with sufficient storage for media and torrents
- A domain (optional, for WireGuard and reverse proxy)

## Quick Start

1) Verify Docker installation

Run `docker --version` and `docker compose version`.

2) Prepare folders

Create host directories that are mounted by the containers (adjust paths if you prefer a different root):

```bash
mkdir -p /data/media/movies /data/media/tv
mkdir -p /data/torrents/movies /data/torrents/tv
mkdir -p /docker/appdata/{jellyfin,prowlarr,qbittorrent,radarr,sonarr,homarr,jellyseerr,wg-easy,beszel-hub,adguard,nginx-proxy-manager}
mkdir -p /docker
```

3) Configure environment

These are referenced by `docker-compose.yml` and should be defined in `.env`. Copy `.env.template` to `.env` and fill these values: 

- `PUID`, `PGID`: container user/group IDs for file permissions
- `TZ`: timezone (e.g., `Europe/Budapest`)
- `JELLYFIN_RENDER_GROUP`: render group id for Jellyfin VAAPI (Linux)
- `WG_HOST`: public hostname for WireGuard Easy
- `WG_ADMIN_PASSWORD_HASH`: hashed admin password (see wg-easy docs)
- `BESZEL_KEY`: key for Beszel agent to connect to hub
- `CF_DDNS_API_TOKEN`: Cloudflare API token (DNS edit scope)
- `CF_DDNS_ZONE_ID`: Cloudflare Zone ID
- `CF_DDNS_SUBDOMAIN`: Subdomain to update (e.g., `vpn`)

4) Cloudflare DDNS

- Place the DDNS config at `/docker/cloudflare-ddns-config.json` (or adjust the volume path in compose). A template is provided in this repo.
- Ensure the `.env` values for Cloudflare are correct and have permissions to edit DNS records.

5) Start the stack

```bash
docker compose up -d
```

6) Set up and test services

- Jellyfin: http://localhost:8096
- Radarr: http://localhost:7878
- Sonarr: http://localhost:8989
- Prowlarr: http://localhost:9696
- qBittorrent: http://localhost:8080
- Jellyseerr: http://localhost:5055
- Homarr: http://localhost:7575
- WireGuard Easy UI: http://localhost:51821
- Beszel Hub: http://localhost:8090
- AdGuard Home: http://localhost:3000
- Nginx Proxy Manager: http://localhost:81

## Troubleshooting

- Permission issues: Verify `PUID`/`PGID` match the owner of `/data` and `/docker/appdata`.
- Hardware acceleration: The current compose maps `/dev/dri` and uses `group_add` for `JELLYFIN_RENDER_GROUP`. See Jellyfin’s Intel Quick Sync guide for details.
- Port conflicts: Make sure host ports (e.g., 80/443 for NPM, 53 for AdGuard) are available and not used by other services on your machine or change the port mappings in `docker-compose.yml`.
- DNS: AdGuard runs in `network_mode: host` and binds to port 53. Conflicts may occur if another DNS service is active on the host.
- Reverse proxy: NPM listens on 80/443; configure your domain and SSL certificates there. Pair with Cloudflare DNS for external access.
- Cloudflare DDNS not updating: Confirm token scope, zone id, and that the mounted config file path matches the compose volume.
- WireGuard admin login: Ensure `WG_ADMIN_PASSWORD_HASH` is valid; consult wg-easy documentation for generating hashes.

## Maintenance

Watchtower runs automatic updates every day at 04:00 and cleans up old images. You can disable or change the schedule via environment variables.

## Useful links

- https://github.com/Ravencentric/awesome-arr
- https://trash-guides.info/
- https://wiki.servarr.com/docker-guide
- https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/#official-docker

## Folder structure

Inspired by this handy [guide](https://trash-guides.info/File-and-Folder-Structure/)

```
/
├── data/
│   ├── media/
│   │   ├── movies/
│   │   └── tv/
│   └── torrents/
│       ├── movies/
│       └── tv/
└── docker/
    ├── .env
    ├── cloudflare-ddns-config.json
    ├── docker-compose.yml
    └── appdata/
        ├── jellyfin/
        ├── radarr/
        ├── sonarr/
        └── etc.
```
