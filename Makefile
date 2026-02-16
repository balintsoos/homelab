.PHONY: help check-docker setup-dirs copy-defaults up down restart logs ps setup clean

# Default target
help:
	@echo "Homelab Docker Stack - Available Commands:"
	@echo ""
	@echo "Setup commands:"
	@echo "  make check-docker    - Verify Docker and Docker Compose installation"
	@echo "  make setup-dirs      - Create all required host directories"
	@echo "  make copy-defaults   - Copy default configuration files"
	@echo "  make setup           - Run full setup (check-docker, setup-dirs, copy-defaults)"
	@echo ""
	@echo "Docker commands:"
	@echo "  make up              - Start all services in detached mode"
	@echo "  make down            - Stop and remove all services"
	@echo "  make restart         - Restart all services"
	@echo "  make logs            - View logs from all services (Ctrl+C to exit)"
	@echo "  make ps              - Show status of all services"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean           - Stop services and remove volumes (WARNING: data loss!)"
	@echo ""

# Verify Docker installation
check-docker:
	@echo "Checking Docker installation..."
	@docker --version
	@docker compose version
	@echo "✓ Docker is installed"

# Create all required directories
setup-dirs:
	@echo "Creating directories for media files and torrents..."
	mkdir -p /data/{media,torrents}/{movies,tv}
	@echo "Creating directories for application data..."
	mkdir -p /docker/appdata/{jellyfin,radarr,sonarr,prowlarr,qbittorrent,homarr/{configs,icons,data},jellyseerr,wg-easy,beszel-hub,adguard/{work,conf},nginx-proxy-manager/{data,letsencrypt},cloudflare-ddns,zigbee2mqtt,mosquitto/{config,data,log},homeassistant}
	@echo "✓ All directories created"

# Copy default configuration files
copy-defaults:
	@echo "Copying default configuration files..."
	cp -r defaults/* /docker/appdata/
	@echo "✓ Default configurations copied"

# Run complete setup
setup: check-docker setup-dirs copy-defaults
	@echo ""
	@echo "✓ Setup complete! Next steps:"
	@echo "  1. Copy env.template to .env and fill in your values"
	@echo "  2. Run 'make up' to start the stack"

# Start all services
up:
	@echo "Starting all services..."
	docker compose up -d
	@echo "✓ Services started"

# Stop all services
down:
	@echo "Stopping all services..."
	docker compose down
	@echo "✓ Services stopped"

# Restart all services
restart:
	@echo "Restarting all services..."
	docker compose restart
	@echo "✓ Services restarted"

# View logs
logs:
	docker compose logs -f

# Show service status
ps:
	docker compose ps

# Clean up everything (WARNING: removes volumes)
clean:
	@echo "WARNING: This will stop services and remove volumes (data loss!)"
	@echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
	@sleep 5
	docker compose down -v
	@echo "✓ Services stopped and volumes removed"
