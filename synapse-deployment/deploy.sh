#!/bin/bash

# Simple Deployment Script (Based on Backup Setup)
# Deploy Synapse Matrix Server on 107.189.19.66

set -e

echo "🚀 Deploying Synapse Matrix Server (Backup-based Setup)"
echo "================================================================"

# Create required directories
echo "📁 Creating data directories..."
mkdir -p volumes/synapse
mkdir -p synapse/templates

# Set proper permissions (Synapse runs as UID 991)
echo "🔐 Setting permissions..."
sudo chown -R 991:991 volumes/synapse
sudo chmod -R 755 volumes/synapse
chmod 755 synapse/templates

# Generate initial configuration and signing key
echo "🔑 Generating initial configuration..."
if [ ! -f "volumes/synapse/homeserver.yaml" ]; then
    echo "Creating initial homeserver configuration..."
    docker run --rm \
        -v $(pwd)/volumes/synapse:/data \
        -e SYNAPSE_SERVER_NAME=107.189.19.66 \
        -e SYNAPSE_REPORT_STATS=no \
        matrixdotorg/synapse:latest \
        generate
    
    # Copy our custom configuration and log config
    sudo cp synapse/homeserver.yaml volumes/synapse/homeserver.yaml
    sudo cp synapse/log.config volumes/synapse/log.config
    sudo chown 991:991 volumes/synapse/homeserver.yaml volumes/synapse/log.config
fi

# Start services
echo "🚀 Starting Synapse services..."
docker-compose up -d

echo "⏳ Waiting for Synapse to start..."
sleep 30

# Check if service is running
echo "📊 Checking service status..."
docker-compose ps

echo ""
echo "✅ Synapse deployment completed!"
echo ""
echo "🌐 Access Information:"
echo "   Synapse Web: http://107.189.19.66:8008"
echo "   Matrix Server: 107.189.19.66:8008"
echo "   Federation Port: 107.189.19.66:8448"
echo ""
echo "👤 Create your first admin user:"
echo "   ./manage.sh create-admin"
echo ""
echo "📋 Useful commands:"
echo "   View logs: ./manage.sh logs"
echo "   Stop services: ./manage.sh stop"
echo "   Restart services: ./manage.sh restart"
echo ""
echo "🎉 Your Matrix homeserver is ready at http://107.189.19.66:8008"
