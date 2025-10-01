#!/bin/bash

# Synapse Management Script
# Provides common management operations for your Synapse deployment

set -e

COMPOSE_FILE="docker-compose.yml"
if [ "$1" = "workers" ]; then
    COMPOSE_FILE="docker-compose.workers.yml"
    shift
fi

case "$1" in
    "start")
        echo "🚀 Starting Synapse services..."
        docker-compose -f "$COMPOSE_FILE" up -d
        ;;
    
    "stop")
        echo "🛑 Stopping Synapse services..."
        docker-compose -f "$COMPOSE_FILE" down
        ;;
    
    "restart")
        echo "🔄 Restarting Synapse services..."
        docker-compose -f "$COMPOSE_FILE" restart
        ;;
    
    "status")
        echo "📊 Service Status:"
        docker-compose -f "$COMPOSE_FILE" ps
        ;;
    
    "logs")
        service="${2:-synapse}"
        echo "📋 Viewing logs for $service..."
        docker-compose -f "$COMPOSE_FILE" logs -f "$service"
        ;;
    
    "update")
        echo "⬆️ Updating Synapse to latest version..."
        docker-compose -f "$COMPOSE_FILE" pull
        docker-compose -f "$COMPOSE_FILE" up -d
        ;;
    
    "backup")
        echo "💾 Creating backup..."
        ./backup.sh
        ;;
    
    "create-user")
        echo "👤 Creating new user..."
        docker-compose -f "$COMPOSE_FILE" exec synapse register_new_matrix_user -c /data/homeserver.yaml http://localhost:8008
        ;;
    
    "create-admin")
        echo "👑 Creating new admin user..."
        docker-compose -f "$COMPOSE_FILE" exec synapse register_new_matrix_user -c /data/homeserver.yaml -a http://localhost:8008
        ;;
    
    "shell")
        service="${2:-synapse}"
        echo "🖥️ Opening shell in $service container..."
        docker-compose -f "$COMPOSE_FILE" exec "$service" /bin/bash
        ;;
    
    "health")
        echo "🏥 Checking service health..."
        curl -s http://localhost:8008/health | jq . || echo "Synapse health check failed"
        docker-compose -f "$COMPOSE_FILE" ps
        ;;
    
    "reset")
        echo "⚠️ WARNING: This will delete ALL data!"
        read -p "Are you sure? Type 'yes' to continue: " confirm
        if [ "$confirm" = "yes" ]; then
            echo "🗑️ Resetting deployment..."
            docker-compose -f "$COMPOSE_FILE" down -v
            sudo rm -rf /opt/synapse/*
            echo "✅ Reset complete. Run ./deploy.sh to redeploy."
        else
            echo "❌ Reset cancelled."
        fi
        ;;
    
    "config")
        echo "📝 Configuration files:"
        echo "Main config: /opt/synapse/data/homeserver.yaml"
        echo "Log config: /opt/synapse/data/log.config"
        echo "Workers: /opt/synapse/data/workers/"
        echo ""
        echo "To edit main config:"
        echo "sudo nano /opt/synapse/data/homeserver.yaml"
        ;;
    
    *)
        echo "🔧 Synapse Management Script"
        echo "Usage: $0 [workers] <command>"
        echo ""
        echo "Commands:"
        echo "  start              Start all services"
        echo "  stop               Stop all services"
        echo "  restart            Restart all services"
        echo "  status             Show service status"
        echo "  logs [service]     Show logs (default: synapse)"
        echo "  update             Update to latest version"
        echo "  backup             Create backup"
        echo "  create-user        Create new user"
        echo "  create-admin       Create new admin user"
        echo "  shell [service]    Open shell in container"
        echo "  health             Check service health"
        echo "  config             Show config file locations"
        echo "  reset              Reset entire deployment (DANGEROUS)"
        echo ""
        echo "Examples:"
        echo "  $0 start                    # Start services"
        echo "  $0 workers start            # Start worker deployment"
        echo "  $0 logs synapse             # View synapse logs"
        echo "  $0 create-admin             # Create admin user"
        ;;
esac
