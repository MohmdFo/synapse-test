#!/bin/bash

# Fix Signing Key Script
# This script fixes the signing key format issue

set -e

echo "🔧 Fixing Synapse signing key..."

SIGNING_KEY_FILE="/opt/synapse/data/signing.key"

# Stop services
echo "🛑 Stopping Synapse services..."
docker-compose down

# Backup existing key if it exists
if [ -f "$SIGNING_KEY_FILE" ]; then
    echo "💾 Backing up existing signing key..."
    cp "$SIGNING_KEY_FILE" "$SIGNING_KEY_FILE.backup.$(date +%Y%m%d-%H%M%S)"
fi

# Generate new signing key in correct format
echo "🔑 Generating new signing key..."
KEY_ID=$(openssl rand -hex 8)
KEY_DATA=$(openssl rand 32 | base64 -w 0)
echo "ed25519 a_${KEY_ID} ${KEY_DATA}" > "$SIGNING_KEY_FILE"

# Set proper permissions
chown 991:991 "$SIGNING_KEY_FILE"
chmod 600 "$SIGNING_KEY_FILE"

echo "✅ Signing key fixed!"
echo "📋 New signing key created at: $SIGNING_KEY_FILE"

# Start services
echo "🚀 Starting Synapse services..."
docker-compose up -d

echo "⏳ Waiting for services to start..."
sleep 30

echo "📊 Checking service status..."
docker-compose ps

echo ""
echo "✅ Fix complete! Check if Synapse is now running properly."
echo "📋 To verify: ./management.sh logs synapse"
