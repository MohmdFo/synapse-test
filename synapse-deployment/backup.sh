#!/bin/bash

# Synapse Backup Script
# Creates backups of database and configuration files

set -e

BACKUP_DIR="/opt/synapse/backups"
DATE=$(date +%Y%m%d-%H%M%S)
COMPOSE_FILE="docker-compose.yml"

echo "💾 Starting Synapse backup process..."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Database backup
echo "📦 Backing up PostgreSQL database..."
docker-compose -f "$COMPOSE_FILE" exec -T db pg_dump -U synapse_user synapse > "$BACKUP_DIR/synapse-db-$DATE.sql"

# Configuration backup
echo "📝 Backing up configuration files..."
tar -czf "$BACKUP_DIR/synapse-config-$DATE.tar.gz" /opt/synapse/data/

# Media backup (optional - can be large)
if [ "$1" = "--include-media" ]; then
    echo "🖼️ Backing up media files..."
    tar -czf "$BACKUP_DIR/synapse-media-$DATE.tar.gz" /opt/synapse/data/media_store/
fi

# Cleanup old backups (keep last 7 days)
echo "🧹 Cleaning up old backups..."
find "$BACKUP_DIR" -name "synapse-*" -type f -mtime +7 -delete

echo "✅ Backup completed!"
echo "📁 Backup files:"
ls -la "$BACKUP_DIR" | grep "$DATE"

echo ""
echo "📋 To restore:"
echo "Database: docker-compose exec -T db psql -U synapse_user synapse < backup-file.sql"
echo "Config: tar -xzf config-backup.tar.gz -C /"
