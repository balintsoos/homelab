<p align="center">
  <img src="logo.png" alt="homelab" width="200">
  <h1 align="center">homelab</h1>
  <p align="center">Self-hosted Docker Compose stack for media automation, smart home, and infrastructure services.</p>
</p>

## Services

| Service | Description | Web UI |
|---------|-------------|------|
| [Jellyfin](https://jellyfin.org/) | Media server | [:8096](http://localhost:8096) |
| [Radarr](https://radarr.video/) | Movie automation | [:7878](http://localhost:7878) |
| [Sonarr](https://sonarr.tv/) | TV automation | [:8989](http://localhost:8989) |
| [Prowlarr](https://prowlarr.com/) | Indexer management | [:9696](http://localhost:9696) |
| [qBittorrent](https://www.qbittorrent.org/) | BitTorrent client | [:8080](http://localhost:8080) |
| [Seerr](https://docs.seerr.dev/) | Media requests | [:5055](http://localhost:5055) |
| [WireGuard Easy](https://github.com/wg-easy/wg-easy) | WireGuard VPN + UI | [:51821](http://localhost:51821) |
| [Beszel](https://beszel.dev/) | Monitoring | [:8090](http://localhost:8090) |
| [AdGuard Home](https://adguard.com/en/adguard-home/overview.html) | DNS filtering | [:3000](http://localhost:3000) |
| [Nginx Proxy Manager](https://nginxproxymanager.com/) | Reverse proxy + SSL | [:81](http://localhost:81) |
| [Cloudflare DDNS](https://github.com/timothymiller/cloudflare-ddns) | Keeps DNS A record updated | - |
| [Zigbee2MQTT](https://www.zigbee2mqtt.io/) | Zigbee to MQTT bridge | [:8081](http://localhost:8081) |
| [Mosquitto](https://mosquitto.org/) | MQTT message broker | - |
| [Home Assistant](https://www.home-assistant.io/) | Home automation platform | [:8123](http://localhost:8123) |

## Requirements

- Docker Engine
- A host with sufficient storage for media and torrents
- A domain (optional, for WireGuard and reverse proxy)

## Quick Start

1. Run `make setup` to verify Docker, create directories, copy default configs, and generate `.env`
2. Edit `.env` and fill in your values
3. Run `docker compose --profile all up -d` to start all services (or pick specific profiles)

## Architecture

**Single compose file** (`compose.yaml`) defines all services as pre-built images.

**Network segmentation** - four isolated Docker networks:
- `proxy` - services exposed through Nginx Proxy Manager
- `media` - Arr stack (Radarr, Sonarr, Prowlarr), qBittorrent, Jellyfin, Seerr
- `iot` - Zigbee2MQTT, Mosquitto (MQTT broker), Home Assistant
- `monitoring` - Beszel hub/agent

**Profiles** - service groups activated with `--profile`:

| Profile | Services |
|---------|----------|
| `media` | Jellyfin, Radarr, Sonarr, Prowlarr, qBittorrent, Seerr |
| `network` | Nginx Proxy Manager, AdGuard Home |
| `vpn` | WireGuard Easy, Cloudflare DDNS |
| `monitoring` | Beszel hub/agent |
| `iot` | Home Assistant, Zigbee2MQTT, Mosquitto |
| `all` | All services |

Start a profile with `docker compose --profile media up -d`. Multiple profiles can be combined: `docker compose --profile media --profile network up -d`. Use `--profile all` to bring up everything.

**Security pattern**: Admin web UIs are bound to `127.0.0.1` (localhost only) and accessed through the reverse proxy (Nginx Proxy Manager) or SSH tunnel. Only public-facing ports (Jellyfin 8096, WireGuard 51820/udp, HTTP/HTTPS 80/443, DNS 53, MQTT 1883/9001) are exposed to the LAN.

**Host paths** (relative to project root):
- `./appdata/{service}/` - persistent config/data per service
- `./data/media/{movies,tv}` - media library
- `./data/torrents/{movies,tv}` - download staging

**Configuration defaults** live in `defaults/` and are copied to `./appdata/` on first setup (`cp -rn`, non-destructive).

## Troubleshooting

**Permission issues:** Verify `PUID`/`PGID` match the owner of `./data` and `./appdata`.

**Hardware acceleration:** The current compose maps `/dev/dri` and uses `group_add` for `JELLYFIN_RENDER_GROUP`. See Jellyfin's Intel Quick Sync guide for details.

**Port conflicts:** Make sure host ports (e.g., 80/443 for NPM, 53 for AdGuard) are available and not used by other services on your machine or change the port mappings in `compose.yaml`.

**DNS:** AdGuard runs in `network_mode: host` and binds to port 53. Conflicts may occur if another DNS service is active on the host.

**Reverse proxy:** NPM listens on 80/443; configure your domain and SSL certificates there. Pair with Cloudflare DNS for external access.

**Cloudflare DDNS not updating:** Confirm token scope, zone id, and that the mounted config file path matches the compose volume.

**WireGuard admin login:** Ensure `WG_ADMIN_PASSWORD_HASH` is valid; consult wg-easy documentation for generating hashes.

**Intel GPU monitoring showing errors or 0% in Beszel:** The host kernel must allow perf events. Check `cat /proc/sys/kernel/perf_event_paranoid` — if it's above 2, lower it with `sudo sysctl kernel.perf_event_paranoid=2`. To persist across reboots: `echo "kernel.perf_event_paranoid=2" | sudo tee /etc/sysctl.d/99-perf.conf`.

**Zigbee2MQTT not starting:** Verify your Zigbee adapter path with `ls -l /dev/serial/by-id/` or `ls /dev/ttyUSB*` and update `ZIGBEE_ADAPTER_PATH` in `.env`. You may need to add your user to the `dialout` group: `sudo usermod -aG dialout $USER`.

## Maintenance

Run `make help` to see available setup, validation, and backup commands. Use `docker compose --profile <name>` directly for starting, stopping, and managing services.

### Backup & Restore

Run `make backup` to stop services, create an archive of all configurations, save it locally, and sync to Google Drive via rclone. Run `make restore BACKUP_FILE=/path/to/archive.tar.gz` to restore from a backup.

Configure `BACKUP_LOCAL_DIR` and `BACKUP_RCLONE_REMOTE` in `.env`. Rclone must be installed and configured separately (`rclone config`).

## Useful links

- https://github.com/Ravencentric/awesome-arr
- https://trash-guides.info/
- https://wiki.servarr.com/docker-guide
- https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/#official-docker

## Folder structure

This follows the [TRaSH Guides hardlink-friendly structure](https://trash-guides.info/File-and-Folder-Structure/How-to-set-up/Docker/) so Radarr/Sonarr can hardlink instead of copy.

```
homelab/
├── data/                                  # Media and downloads
│   ├── media/                             # Organized media library
│   │   ├── movies/                        # Movies for Jellyfin
│   │   └── tv/                            # TV shows for Jellyfin
│   └── torrents/                          # Download staging area
│       ├── movies/                        # Movie downloads
│       └── tv/                            # TV show downloads
│
├── appdata/                               # Container persistent data
│   ├── adguard/                           # AdGuard Home config
│   ├── beszel/                            # Beszel monitoring
│   │   ├── hub/                           # Beszel hub data
│   │   ├── agent/                         # Beszel agent data
│   │   └── socket/                        # Shared Unix socket
│   ├── cloudflare-ddns/                   # Cloudflare DDNS config
│   ├── homeassistant/                     # Home Assistant configuration
│   ├── jellyfin/                          # Jellyfin media server data
│   ├── mosquitto/                         # Mosquitto MQTT broker config
│   ├── nginx-proxy-manager/               # NPM proxy config
│   ├── prowlarr/                          # Prowlarr indexer config
│   ├── qbittorrent/                       # qBittorrent settings
│   ├── radarr/                            # Radarr movie automation
│   ├── seerr/                             # Seerr request data
│   ├── sonarr/                            # Sonarr TV automation
│   ├── wg-easy/                           # WireGuard VPN config
│   └── zigbee2mqtt/                       # Zigbee2MQTT config and database
│
├── defaults/                              # Default configuration templates
│   ├── cloudflare-ddns/                   # Cloudflare DDNS config template
│   ├── mosquitto/                         # Mosquitto MQTT config template
│   └── zigbee2mqtt/                       # Zigbee2MQTT config template
│
├── .env                                   # Environment variables
├── compose.yaml                           # Main compose file
└── env.template                           # Environment variables template
```
