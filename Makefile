.PHONY: help check-docker setup-dirs copy-defaults copy-env up down restart logs ps setup backup restore

# Default target
help:
	@echo "Homelab Docker Stack - Available Commands:"
	@echo ""
	@echo "Setup commands:"
	@echo "  make check-docker    - Verify Docker and Docker Compose installation"
	@echo "  make setup-dirs      - Create all required host directories"
	@echo "  make copy-defaults   - Copy default configuration files"
	@echo "  make copy-env        - Copy env.template to .env (won't overwrite existing)"
	@echo "  make setup           - Run full setup (check-docker, setup-dirs, copy-defaults, copy-env)"
	@echo ""
	@echo "Docker commands:"
	@echo "  make up              - Start all services in detached mode"
	@echo "  make down            - Stop and remove all services"
	@echo "  make restart         - Restart all services"
	@echo "  make logs            - View logs from all services (Ctrl+C to exit)"
	@echo "  make ps              - Show status of all services"
	@echo ""
	@echo "Backup commands:"
	@echo "  make backup          - Back up configs and sync to Google Drive via rclone"
	@echo "  make restore         - Restore from backup (BACKUP_FILE=/path/to/archive.tar.gz)"
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
	mkdir -p /docker/appdata/{jellyfin,radarr,sonarr,prowlarr,qbittorrent,seerr,wg-easy,beszel-hub,adguard/{work,conf},nginx-proxy-manager/{data,letsencrypt},cloudflare-ddns,zigbee2mqtt,mosquitto/{config,data,log},homeassistant}
	mkdir -p $${BACKUP_LOCAL_DIR:-/docker/backups}
	@echo "✓ All directories created"

# Copy default configuration files
copy-defaults:
	@echo "Copying default configuration files..."
	cp -rn defaults/* /docker/appdata/
	@echo "✓ Default configurations copied (existing files were not overwritten)"

# Copy env.template to .env if it doesn't exist
copy-env:
	@if [ -f .env ]; then \
		echo "✓ .env already exists, skipping (remove it first to regenerate)"; \
	else \
		cp env.template .env; \
		echo "✓ .env created from env.template — edit it with your values"; \
	fi

# Run complete setup
setup: check-docker setup-dirs copy-defaults copy-env
	@echo ""
	@echo "✓ Setup complete! Next steps:"
	@echo "  1. Edit .env and fill in your values"
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

# Back up configs and data
backup:
	@echo "Starting backup..."
	@mkdir -p $${BACKUP_LOCAL_DIR:-/docker/backups}
	docker compose down
	@TIMESTAMP=$$(date +%Y-%m-%d-%H%M%S); \
	ARCHIVE="$${BACKUP_LOCAL_DIR:-/docker/backups}/homelab-backup-$$TIMESTAMP.tar.gz"; \
	tar -czf "$$ARCHIVE" -C / docker/appdata -C $(CURDIR) .env docker-compose.yml; \
	echo "✓ Archive created: $$ARCHIVE ($$(du -sh "$$ARCHIVE" | cut -f1))"; \
	if command -v rclone >/dev/null 2>&1 && [ -n "$${BACKUP_RCLONE_REMOTE}" ]; then \
		rclone copy "$$ARCHIVE" "$${BACKUP_RCLONE_REMOTE}"; \
		echo "✓ Synced to $${BACKUP_RCLONE_REMOTE}"; \
	else \
		echo "⚠ rclone not found or BACKUP_RCLONE_REMOTE not set, skipping remote sync"; \
	fi
	docker compose up -d
	@echo "✓ Backup complete, services restarted"

# Restore from a backup archive
restore:
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "Usage: make restore BACKUP_FILE=/path/to/homelab-backup-YYYY-MM-DD-HHMMSS.tar.gz"; \
		exit 1; \
	fi
	@if [ ! -f "$(BACKUP_FILE)" ]; then \
		echo "Error: $(BACKUP_FILE) not found"; \
		exit 1; \
	fi
	@echo "Restoring from $(BACKUP_FILE)..."
	-docker compose down
	tar -xzf "$(BACKUP_FILE)" -C / docker/appdata
	tar -xzf "$(BACKUP_FILE)" -C $(CURDIR) .env docker-compose.yml
	docker compose up -d
	@echo "✓ Restore complete, services started"
