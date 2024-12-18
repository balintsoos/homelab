# homelab

My containerized home server setup

## Requirements

- a computer where you will run your server
- an operating system, preferably a linux distro, like ubuntu or debian
- Docker Engine installed

## Services

- [Jellyfin](https://jellyfin.org/)
- [Jellyseerr](https://github.com/Fallenbagel/jellyseerr)
- [Radarr](https://radarr.video/)
- [Sonarr](https://sonarr.tv/)
- [Prowlarr](https://prowlarr.com/)
- [qBittorrent](https://www.qbittorrent.org/)
- [Nginx Proxy Manager](https://nginxproxymanager.com/)
- [Homarr](https://homarr.dev/)
- [WireGuard Easy](https://github.com/wg-easy/wg-easy)
- [DuckDNS](https://github.com/linuxserver/docker-duckdns)
- [Watchtower](https://containrrr.dev/watchtower/)

## Useful links

- https://trash-guides.info/
- https://wiki.servarr.com/docker-guide
- https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/#official-docker

## Folder structure

Inspired by this handy [guide](https://trash-guides.info/File-and-Folder-Structure/)

```
/data
├── media
│   ├── movies
│   └── tv
└── torrents
    ├── movies
    └── tv
/docker
└── appdata
    ├── duckdns
    ├── homarr
    ├── jellyfin
    ├── jellyseerr
    ├── nginx-proxy-manager
    ├── prowlarr
    ├── qbittorrent
    ├── radarr
    ├── sonarr
    └── wg-easy
```
