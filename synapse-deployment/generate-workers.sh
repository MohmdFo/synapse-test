#!/bin/bash

# Generate Worker Configuration Files
# This script creates worker configuration files for scaling Synapse

set -e

CONFIG_DIR="$1"
if [ -z "$CONFIG_DIR" ]; then
    CONFIG_DIR="/opt/synapse/data"
fi

WORKERS_DIR="$CONFIG_DIR/workers"
mkdir -p "$WORKERS_DIR"

echo "🔧 Generating worker configuration files..."

# Generic Worker 1
cat > "$WORKERS_DIR/generic-worker-1.yaml" << 'EOF'
worker_app: synapse.app.generic_worker
worker_name: generic-worker-1

worker_listeners:
  - type: http
    port: 8081
    resources:
      - names: [client, federation]

worker_replication_host: synapse
worker_replication_http_port: 9093

# Log configuration
worker_log_config: /data/log.config
EOF

# Federation Sender Worker
cat > "$WORKERS_DIR/federation-sender.yaml" << 'EOF'
worker_app: synapse.app.federation_sender
worker_name: federation-sender

worker_replication_host: synapse
worker_replication_http_port: 9093

# Log configuration
worker_log_config: /data/log.config
EOF

# Media Repository Worker
cat > "$WORKERS_DIR/media-repository.yaml" << 'EOF'
worker_app: synapse.app.media_repository
worker_name: media-repository

worker_listeners:
  - type: http
    port: 8083
    resources:
      - names: [media]

worker_replication_host: synapse
worker_replication_http_port: 9093

# Log configuration
worker_log_config: /data/log.config
EOF

# Update main homeserver.yaml to include worker settings
if [ -f "$CONFIG_DIR/homeserver.yaml" ]; then
    echo "🔄 Updating main homeserver.yaml for worker mode..."
    
    # Add replication listener if not present
    if ! grep -q "port: 9093" "$CONFIG_DIR/homeserver.yaml"; then
        cat >> "$CONFIG_DIR/homeserver.yaml" << 'EOF'

# Replication listener for workers
listeners:
  - port: 8008
    type: http
    tls: false
    bind_addresses: ['::1', '127.0.0.1', '0.0.0.0']
    resources:
      - names: [client, federation]
        compress: false
  
  # Replication listener for workers
  - port: 9093
    type: http
    bind_addresses: ['127.0.0.1']
    resources:
      - names: [replication]

# Worker configuration
send_federation: false  # Disable federation sending on main process

# Route specific endpoints to workers
instance_map:
  generic-worker-1:
    host: synapse-generic-worker-1
    port: 8081
  media-repository:
    host: synapse-media-repository
    port: 8083

stream_writers:
  events: generic-worker-1
  typing: generic-worker-1
  to_device: generic-worker-1
  account_data: generic-worker-1
  receipts: generic-worker-1
  presence: generic-worker-1
EOF
    fi
fi

# Set proper permissions
chown -R 991:991 "$WORKERS_DIR"
chmod -R 644 "$WORKERS_DIR"/*.yaml

echo "✅ Worker configuration files generated:"
echo "   - $WORKERS_DIR/generic-worker-1.yaml"
echo "   - $WORKERS_DIR/federation-sender.yaml"
echo "   - $WORKERS_DIR/media-repository.yaml"
echo ""
echo "📋 To use workers, run:"
echo "   docker-compose -f docker-compose.workers.yml up -d"
