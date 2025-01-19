# homelab

My containerized home server setup

## Requirements

- Linux
- Docker Engine

## Services

- [Jellyfin](https://jellyfin.org/)
- [Radarr](https://radarr.video/)
- [Sonarr](https://sonarr.tv/)
- [Prowlarr](https://prowlarr.com/)
- [qBittorrent](https://www.qbittorrent.org/)
- [Jellyseerr](https://github.com/Fallenbagel/jellyseerr)
- [Homarr](https://homarr.dev/)
- [WireGuard Easy](https://github.com/wg-easy/wg-easy)
- [DuckDNS](https://github.com/linuxserver/docker-duckdns)
- [Watchtower](https://containrrr.dev/watchtower/)
- [Beszel](https://beszel.dev/)
- [AdGuard Home](https://adguard.com/en/adguard-home/overview.html)

## Useful links

- https://github.com/Ravencentric/awesome-arr
- https://trash-guides.info/
- https://wiki.servarr.com/docker-guide
- https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/#official-docker

## Folder structure

Inspired by this handy [guide](https://trash-guides.info/File-and-Folder-Structure/)

```
.
├── data
│   ├── media
│   │   ├── movies
│   │   └── tv
│   └── torrents
│       ├── movies
│       └── tv
└── docker
    └── appdata
        ├── jellyfin
        ├── prowlarr
        ├── qbittorrent
        ├── radarr
        ├── sonarr
        └── ...
```
