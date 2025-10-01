#!/bin/bash

# Quick Configuration Fix Script
# This script fixes the email registration requirement issue

set -e

echo "🔧 Fixing Synapse configuration..."

CONFIG_FILE="/opt/synapse/data/homeserver.yaml"

# Stop services first
echo "🛑 Stopping Synapse services..."
docker-compose down

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found at $CONFIG_FILE"
    exit 1
fi

# Backup the config
echo "💾 Backing up configuration..."
cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%Y%m%d-%H%M%S)"

# Fix the registration configuration
echo "📝 Fixing registration configuration..."

# Remove or comment out the email requirement
sed -i 's/registrations_require_3pid:/# registrations_require_3pid:/' "$CONFIG_FILE"
sed -i 's/  - email/  # - email/' "$CONFIG_FILE"

# Make sure registration without verification is enabled
if grep -q "enable_registration_without_verification:" "$CONFIG_FILE"; then
    sed -i 's/enable_registration_without_verification: false/enable_registration_without_verification: true/' "$CONFIG_FILE"
else
    # Add the setting if it doesn't exist
    sed -i '/enable_registration: true/a enable_registration_without_verification: true' "$CONFIG_FILE"
fi

# Add suppress key server warning to reduce noise
if ! grep -q "suppress_key_server_warning:" "$CONFIG_FILE"; then
    echo "suppress_key_server_warning: true" >> "$CONFIG_FILE"
fi

echo "✅ Configuration fixed!"

# Start services
echo "🚀 Starting Synapse services..."
docker-compose up -d

echo "⏳ Waiting for services to start..."
sleep 30

echo "📊 Checking service status..."
docker-compose ps

echo ""
echo "✅ Fix complete! Synapse should now start properly."
echo "📋 To verify: ./management.sh logs synapse"
