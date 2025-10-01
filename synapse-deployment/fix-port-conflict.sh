#!/bin/bash

# Fix Port 8008 Conflict for Synapse Deployment
# This script resolves the "Address already in use" error

set -e

echo "🔍 Checking for port 8008 conflicts..."

# Function to check what's using port 8008
check_port_8008() {
    echo "📋 Processes using port 8008:"
    if command -v lsof >/dev/null 2>&1; then
        lsof -i :8008 || echo "No processes found using lsof"
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tlnp | grep :8008 || echo "No processes found using netstat"
    elif command -v ss >/dev/null 2>&1; then
        ss -tlnp | grep :8008 || echo "No processes found using ss"
    else
        echo "No network tools available to check port usage"
    fi
}

# Function to stop all Docker containers
stop_all_containers() {
    echo "🛑 Stopping all Docker containers..."
    docker stop $(docker ps -q) 2>/dev/null || echo "No running containers to stop"
    sleep 5
}

# Function to remove containers
cleanup_containers() {
    echo "🧹 Removing Synapse-related containers..."
    docker rm -f synapse postgres redis nginx 2>/dev/null || echo "Some containers may not exist"
    docker rm -f $(docker ps -aq --filter "name=synapse*") 2>/dev/null || echo "No synapse containers to remove"
    sleep 2
}

# Function to kill processes on port 8008
kill_port_processes() {
    echo "💀 Killing processes on port 8008..."
    if command -v lsof >/dev/null 2>&1; then
        local pids=$(lsof -ti :8008)
        if [ ! -z "$pids" ]; then
            echo "Killing PIDs: $pids"
            kill -9 $pids 2>/dev/null || echo "Failed to kill some processes"
            sleep 3
        fi
    fi
}

# Function to restart Docker daemon
restart_docker() {
    echo "🔄 Restarting Docker daemon..."
    sudo systemctl restart docker 2>/dev/null || sudo service docker restart 2>/dev/null || echo "Could not restart Docker daemon"
    sleep 10
}

# Main execution
echo "🚀 Starting port conflict resolution..."

# Step 1: Check current port usage
check_port_8008

# Step 2: Stop all containers
stop_all_containers

# Step 3: Clean up containers
cleanup_containers

# Step 4: Kill any remaining processes on port 8008
kill_port_processes

# Step 5: Check port again
echo "🔍 Checking port 8008 after cleanup..."
check_port_8008

# Step 6: Optional Docker restart (uncomment if needed)
# read -p "Do you want to restart Docker daemon? (y/N): " -n 1 -r
# echo
# if [[ $REPLY =~ ^[Yy]$ ]]; then
#     restart_docker
# fi

echo "✅ Port conflict resolution complete!"
echo ""
echo "📝 Next steps:"
echo "1. Run: ./deploy.sh"
echo "2. If still failing, uncomment the Docker restart section in this script"
echo "3. Monitor logs with: ./management.sh logs synapse"

# Final port check
echo ""
echo "🔍 Final port 8008 status:"
check_port_8008
