#!/bin/bash

# Comprehensive Port Conflict Resolution for Synapse
# This script will identify and resolve port conflicts for Synapse deployment

set -e

echo "🔍 Starting comprehensive port conflict analysis..."

# Function to check what's using specific ports
check_port_usage() {
    local port=$1
    echo "📋 Checking port $port usage:"
    
    # Check with different tools available
    if command -v lsof >/dev/null 2>&1; then
        echo "Using lsof:"
        lsof -i :$port 2>/dev/null || echo "No processes found on port $port (lsof)"
    fi
    
    if command -v netstat >/dev/null 2>&1; then
        echo "Using netstat:"
        netstat -tlnp 2>/dev/null | grep :$port || echo "No processes found on port $port (netstat)"
    fi
    
    if command -v ss >/dev/null 2>&1; then
        echo "Using ss:"
        ss -tlnp 2>/dev/null | grep :$port || echo "No processes found on port $port (ss)"
    fi
    
    # Check docker containers using the port
    echo "Docker containers using port $port:"
    docker ps --format "table {{.Names}}\t{{.Ports}}" | grep :$port || echo "No Docker containers using port $port"
    
    echo "---"
}

# Function to kill processes on a specific port
kill_processes_on_port() {
    local port=$1
    echo "💀 Attempting to kill processes on port $port..."
    
    if command -v lsof >/dev/null 2>&1; then
        local pids=$(lsof -ti :$port 2>/dev/null)
        if [ ! -z "$pids" ]; then
            echo "Found PIDs using port $port: $pids"
            echo $pids | xargs kill -9 2>/dev/null || echo "Some processes could not be killed"
            sleep 2
        else
            echo "No processes found using port $port"
        fi
    fi
}

# Main analysis
echo "🌐 Checking critical ports for Synapse..."

# Check ports 8008, 8448, and 3000
for port in 8008 8448 3000; do
    check_port_usage $port
done

# Check all running containers
echo "📦 All running Docker containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo "---"

# Stop all Synapse-related containers
echo "🛑 Stopping Synapse deployment..."
cd /root/synapse-test/synapse-deployment
./management.sh stop 2>/dev/null || echo "No Synapse containers to stop"

echo "🧹 Cleaning up any remaining Synapse containers..."
docker rm -f synapse synapse-db synapse-redis 2>/dev/null || echo "Some containers already removed"

# Kill processes on Synapse ports
kill_processes_on_port 8008
kill_processes_on_port 8448

# Check if RocketChat is conflicting
echo "🚀 RocketChat container status:"
docker ps | grep rocketchat || echo "No RocketChat containers running"

# Offer to change Synapse port if 8008 is still occupied
echo "🔍 Final port check..."
check_port_usage 8008

if lsof -i :8008 >/dev/null 2>&1 || netstat -tln 2>/dev/null | grep :8008 >/dev/null || ss -tln 2>/dev/null | grep :8008 >/dev/null; then
    echo "⚠️  WARNING: Port 8008 is still in use!"
    echo ""
    echo "Options:"
    echo "1. Stop the service using port 8008"
    echo "2. Change Synapse to use a different port (like 8080)"
    echo "3. Restart the system to clear all port bindings"
    echo ""
    read -p "Do you want to change Synapse to use port 8080 instead? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔧 Updating Docker Compose to use port 8080..."
        sed -i 's/"8008:8008"/"8080:8008"/g' docker-compose.yml
        echo "✅ Updated! Synapse will now be available at http://107.189.19.66:8080"
        echo "📝 Remember to update your client configuration to use port 8080"
    fi
else
    echo "✅ Port 8008 is now free!"
fi

echo ""
echo "🎯 Summary:"
echo "- Stopped all Synapse containers"
echo "- Killed processes on ports 8008 and 8448"
echo "- Ready for deployment"
echo ""
echo "📝 Next steps:"
echo "1. Run: ./deploy.sh"
echo "2. Monitor with: ./management.sh logs synapse"
echo "3. Test access: curl http://107.189.19.66:8008/health (or 8080 if changed)"

# Final status
echo ""
echo "🔍 Final system status:"
echo "Ports 8008 and 8448:"
check_port_usage 8008
check_port_usage 8448
