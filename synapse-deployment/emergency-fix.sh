#!/bin/bash

# Emergency Fix for Synapse Logging Issue
# Run this on the server to fix the "File name too long" error

set -e

echo "🚨 Emergency Fix: Resolving Synapse logging configuration issue"
echo "================================================================"

# Stop the failing containers
echo "🛑 Stopping failed containers..."
docker-compose down

# Pull latest fixes from repository
echo "📥 Pulling latest fixes..."
git pull origin main

# Clean up the data directory to start fresh
echo "🧹 Cleaning up data directory..."
sudo rm -rf volumes/synapse/*

# Run the updated deployment
echo "🚀 Running fixed deployment..."
./deploy.sh

echo "✅ Emergency fix completed!"
echo ""
echo "🔍 Check the logs to verify it's working:"
echo "   ./manage.sh logs"
