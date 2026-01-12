.PHONY: help setup start stop restart status logs backup restore service

help:
	@echo "get-ntfyd Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make setup          - First-time setup"
	@echo "  make start          - Start services"
	@echo "  make stop           - Stop services"
	@echo "  make restart        - Restart services"
	@echo "  make status         - Show service status"
	@echo "  make logs           - View logs"
	@echo "  make service        - Interactive service manager"
	@echo "  make backup         - Create backup"
	@echo "  make restore        - Restore from backup"
	@echo ""

setup:
	@./scripts/setup.sh

start:
	@./scripts/start.sh

stop:
	@docker compose down

restart:
	@docker compose restart

status:
	@docker compose ps

logs:
	@docker compose logs -f

service:
	@./scripts/service.sh

backup:
	@./scripts/backup.sh

restore:
	@ls -lh backup/*.tar.gz 2>/dev/null || echo "No backups found"
	@read -p "Enter backup file path: " backup_file; \
	./scripts/restore.sh "$$backup_file"
