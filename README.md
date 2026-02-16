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
- [Zigbee2MQTT](https://www.zigbee2mqtt.io/) - Zigbee to MQTT bridge for smart home devices
- [Mosquitto](https://mosquitto.org/) - MQTT message broker
- [Home Assistant](https://www.home-assistant.io/) - Home automation platform

## Requirements

- Docker Engine
- A host with sufficient storage for media and torrents
- A domain (optional, for WireGuard and reverse proxy)

## Quick Start

1) Verify Docker installation

Run `docker --version` and `docker compose version`.

Or use the Makefile:
```bash
make check-docker
```

2) Configure environment

Environment variables are referenced by `docker-compose.yml` and should be defined in `.env`. Copy `env.template` to `.env` and fill the values. You can find more details in the template file. 

3) Prepare folders

Create host directories that are mounted by the containers. Adjust paths if you prefer a different root.

Create directories for media files and torrents:

```bash
mkdir -p /data/{media,torrents}/{movies,tv}
```

Create directories for application data and configurations:

```bash
mkdir -p /docker/appdata/{jellyfin,radarr,sonarr,prowlarr,qbittorrent,homarr/{configs,icons,data},jellyseerr,wg-easy,beszel-hub,adguard/{work,conf},nginx-proxy-manager/{data,letsencrypt},cloudflare-ddns,zigbee2mqtt,mosquitto/{config,data,log},homeassistant}
```

Or use the Makefile to create all directories at once:
```bash
make setup-dirs
```

4) Copy default configurations

Copy the default config files from the `defaults/` folder to the `appdata/` directory:

```bash
cp -r defaults/* /docker/appdata/
```

Or use the Makefile:
```bash
make copy-defaults
```

5) Start the stack

```bash
docker compose up -d
```

Or use the Makefile:
```bash
make up
```

**Tip:** Run `make setup` to execute steps 1, 3, and 4 automatically, or run `make help` to see all available commands.

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
- Zigbee2MQTT: http://localhost:8081
- Home Assistant: http://localhost:8123

## Troubleshooting

- Permission issues: Verify `PUID`/`PGID` match the owner of `/data` and `/docker/appdata`.
- Hardware acceleration: The current compose maps `/dev/dri` and uses `group_add` for `JELLYFIN_RENDER_GROUP`. See Jellyfin’s Intel Quick Sync guide for details.
- Port conflicts: Make sure host ports (e.g., 80/443 for NPM, 53 for AdGuard) are available and not used by other services on your machine or change the port mappings in `docker-compose.yml`.
- DNS: AdGuard runs in `network_mode: host` and binds to port 53. Conflicts may occur if another DNS service is active on the host.
- Reverse proxy: NPM listens on 80/443; configure your domain and SSL certificates there. Pair with Cloudflare DNS for external access.
- Cloudflare DDNS not updating: Confirm token scope, zone id, and that the mounted config file path matches the compose volume.
- WireGuard admin login: Ensure `WG_ADMIN_PASSWORD_HASH` is valid; consult wg-easy documentation for generating hashes.
- Zigbee2MQTT not starting: Verify your Zigbee adapter path with `ls -l /dev/serial/by-id/` or `ls /dev/ttyUSB*` and update `ZIGBEE_ADAPTER_PATH` in `.env`. You may need to add your user to the `dialout` group: `sudo usermod -aG dialout $USER`.

## Maintenance

Watchtower runs automatic updates every day at 04:00 and cleans up old images. You can disable or change the schedule via environment variables.

### Managing Services

Use `docker compose` commands or the provided Makefile:

- **View logs:** `docker compose logs -f` or `make logs`
- **Check status:** `docker compose ps` or `make ps`
- **Restart services:** `docker compose restart` or `make restart`
- **Stop services:** `docker compose down` or `make down`

Run `make help` to see all available commands.

## Useful links

- https://github.com/Ravencentric/awesome-arr
- https://trash-guides.info/
- https://wiki.servarr.com/docker-guide
- https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/#official-docker

## Folder structure

Inspired by this handy [guide](https://trash-guides.info/File-and-Folder-Structure/How-to-set-up/Docker/)

```
/
├── data/                                  # Media and downloads
│   ├── media/                             # Organized media library
│   │   ├── movies/                        # Movies for Jellyfin
│   │   └── tv/                            # TV shows for Jellyfin
│   └── torrents/                          # Download staging area
│       ├── movies/                        # Movie downloads
│       └── tv/                            # TV show downloads
│
└── docker/                                # Docker stack configuration
    ├── .env                               # Environment variables
    ├── docker-compose.yml                 # Main compose file
    ├── env.template                       # Environment variables template
    │
    ├── appdata/                           # Container persistent data
    │   ├── adguard/                       # AdGuard Home config
    │   ├── beszel-hub/                    # Beszel monitoring data
    │   ├── cloudflare-ddns/               # Cloudflare DDNS config
    │   ├── homeassistant/                 # Home Assistant configuration
    │   ├── homarr/                        # Homarr dashboard config
    │   ├── jellyfin/                      # Jellyfin media server data
    │   ├── jellyseerr/                    # Jellyseerr request data
    │   ├── mosquitto/                     # Mosquitto MQTT broker config
    │   ├── nginx-proxy-manager/           # NPM proxy config
    │   ├── prowlarr/                      # Prowlarr indexer config
    │   ├── qbittorrent/                   # qBittorrent settings
    │   ├── radarr/                        # Radarr movie automation
    │   ├── sonarr/                        # Sonarr TV automation
    │   ├── wg-easy/                       # WireGuard VPN config
    │   └── zigbee2mqtt/                   # Zigbee2MQTT config and database
    │
    └── defaults/                          # Default configuration templates
        ├── cloudflare-ddns/               # Cloudflare DDNS config template
        ├── mosquitto/                     # Mosquitto MQTT config template
        └── zigbee2mqtt/                   # Zigbee2MQTT config template
```
