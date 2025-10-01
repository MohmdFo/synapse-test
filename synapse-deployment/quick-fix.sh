#!/bin/bash

# Quick Fix Script for Permission Issues
# Run this on the server to fix the deployment

set -e

echo "🔧 Fixing Synapse deployment issues..."

# Stop any running containers
echo "🛑 Stopping services..."
docker-compose down 2>/dev/null || true

# Fix permissions (Synapse runs as UID 991)
echo "🔐 Fixing permissions..."
sudo chown -R 991:991 volumes/synapse 2>/dev/null || true
sudo chmod -R 755 volumes/synapse 2>/dev/null || true

# Generate basic synapse configuration first
echo "🔑 Generating Synapse configuration..."
if [ ! -f "volumes/synapse/107.189.19.66.signing.key" ]; then
    # Use the generate command correctly
    docker run --rm \
        -v $(pwd)/volumes/synapse:/data \
        -e SYNAPSE_SERVER_NAME=107.189.19.66 \
        -e SYNAPSE_REPORT_STATS=no \
        matrixdotorg/synapse:latest \
        generate
fi

# Copy our simplified config
echo "📝 Applying custom configuration..."
sudo cp synapse/homeserver.yaml volumes/synapse/homeserver.yaml
sudo cp synapse/log.config volumes/synapse/log.config
sudo chown 991:991 volumes/synapse/homeserver.yaml volumes/synapse/log.config

echo "✅ Fix applied! Now run: ./deploy.sh"
