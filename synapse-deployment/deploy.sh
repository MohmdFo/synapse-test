#!/bin/bash

# Synapse Independent Deployment Script for Server 107.189.19.66
# This script deploys Synapse using pre-built images (no source code dependency)

set -e

# Server configuration
SERVER_IP="107.189.19.66"
DATA_DIR="/opt/synapse"
COMPOSE_FILE="docker-compose.yml"

echo "🚀 Deploying Synapse on Server $SERVER_IP (Independent Deployment)"
echo "================================================================"
echo ""

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  This script needs to run with sudo for directory creation"
    echo "   Please run: sudo ./deploy.sh"
    exit 1
fi

# Create data directories with proper permissions
echo "📁 Creating data directories..."
mkdir -p "$DATA_DIR"/{data,postgres,redis}
chown -R 991:991 "$DATA_DIR"
chmod -R 755 "$DATA_DIR"

# Install Docker and Docker Compose if not present
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl enable docker
    systemctl start docker
    rm get-docker.sh
fi

if ! command -v docker-compose &> /dev/null; then
    echo "🔧 Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Generate homeserver configuration if it doesn't exist
if [ ! -f "$DATA_DIR/data/homeserver.yaml" ]; then
    echo "📝 Generating custom Synapse configuration..."
    
    # Create the homeserver configuration from our template
    ./generate-config.sh "$SERVER_IP" "$DATA_DIR/data"
    
    echo "✅ Configuration generated!"
else
    echo "📋 Configuration already exists, skipping generation..."
fi

# Start services
echo "🚀 Starting Synapse services..."
docker-compose -f "$COMPOSE_FILE" up -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 30

# Check if services are running
echo "📊 Checking service status..."
docker-compose -f "$COMPOSE_FILE" ps

echo ""
echo "✅ Synapse deployment completed!"
echo ""
echo "🌐 Access Information:"
echo "   Synapse Web: http://$SERVER_IP:8008"
echo "   Matrix Server: $SERVER_IP:8008"
echo "   Federation Port: $SERVER_IP:8448"
echo ""
echo "👤 Create your first admin user:"
echo "   docker-compose exec synapse register_new_matrix_user -c /data/homeserver.yaml -a http://localhost:8008"
echo ""
echo "📋 Useful commands:"
echo "   View logs: docker-compose logs -f"
echo "   Stop services: docker-compose down"
echo "   Restart services: docker-compose restart"
echo ""
echo "🔒 Security Notes:"
echo "   - Change default passwords in the configuration"
echo "   - Set up SSL/TLS for production use"
echo "   - Configure firewall rules"
echo "   - Disable registration after creating admin user"
echo ""
echo "🎉 Your Matrix homeserver is ready at http://$SERVER_IP:8008"
