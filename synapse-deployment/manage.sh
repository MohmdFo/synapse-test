#!/bin/bash

# Simple Management Script for Synapse (Based on Backup Setup)

set -e

COMMAND=${1:-help}

case $COMMAND in
    "start"|"up")
        echo "🚀 Starting Synapse services..."
        docker-compose up -d
        echo "✅ Synapse started!"
        echo "🌐 Access: http://107.189.19.66:8008"
        ;;
    
    "stop"|"down")
        echo "🛑 Stopping Synapse services..."
        docker-compose down
        echo "✅ Synapse stopped!"
        ;;
    
    "restart")
        echo "🔄 Restarting Synapse services..."
        docker-compose restart
        echo "✅ Synapse restarted!"
        ;;
    
    "logs")
        SERVICE=${2:-synapse}
        echo "📋 Viewing logs for $SERVICE..."
        docker-compose logs -f $SERVICE
        ;;
    
    "status")
        echo "📊 Synapse service status:"
        docker-compose ps
        ;;
    
    "create-admin")
        echo "👤 Creating admin user..."
        echo "📝 Follow the prompts to create your admin user:"
        docker-compose exec synapse register_new_matrix_user -c /data/homeserver.yaml -a http://localhost:8008
        ;;
    
    "shell")
        echo "🐚 Opening shell in Synapse container..."
        docker-compose exec synapse /bin/bash
        ;;
    
    "clean")
        echo "🧹 Cleaning up Synapse deployment..."
        docker-compose down -v
        echo "⚠️  All data will be lost! Continue? (y/N)"
        read -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo rm -rf volumes/
            echo "✅ Cleanup complete!"
        else
            echo "❌ Cleanup cancelled"
        fi
        ;;
    
    "help"|*)
        echo "🏠 Synapse Management Script (Backup-based Setup)"
        echo ""
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  start        Start Synapse services"
        echo "  stop         Stop Synapse services"
        echo "  restart      Restart Synapse services"
        echo "  logs [svc]   View logs (default: synapse)"
        echo "  status       Show service status"
        echo "  create-admin Create admin user"
        echo "  shell        Open shell in Synapse container"
        echo "  clean        Clean up all data (DESTRUCTIVE)"
        echo "  help         Show this help"
        echo ""
        echo "🌐 Access: http://107.189.19.66:8008"
        ;;
esac
