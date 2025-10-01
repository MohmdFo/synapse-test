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

# Set proper permissions
echo "🔐 Setting permissions..."
chmod 755 volumes/synapse
chmod 755 synapse/templates

# Generate signing key if it doesn't exist
if [ ! -f "volumes/synapse/107.189.19.66.signing.key" ]; then
    echo "🔑 Generating signing key..."
    docker run --rm \
        -v $(pwd)/volumes/synapse:/data \
        matrixdotorg/synapse:latest \
        generate-keys -c /data/homeserver.yaml
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
