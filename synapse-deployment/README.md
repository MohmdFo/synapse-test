# Synapse Matrix Homeserver - Backup-based Setup

This deployment is based on your working backup configuration, simplified for bare IP deployment on **107.189.19.66**.

## 🚀 Quick Start

### Deploy Synapse
```bash
./deploy.sh
```

### Manage Services
```bash
# Start services
./manage.sh start

# View logs
./manage.sh logs

# Create admin user
./manage.sh create-admin

# Stop services
./manage.sh stop
```

## 🌐 Access

- **Synapse Web Interface**: http://107.189.19.66:8008
- **Matrix Server**: 107.189.19.66:8008
- **Federation**: 107.189.19.66:8448

## 📁 Directory Structure

```
synapse-deployment/
├── docker-compose.yml          # Main service definition
├── deploy.sh                   # Deployment script
├── manage.sh                   # Management script
├── synapse/
│   ├── homeserver.yaml        # Synapse configuration
│   └── templates/             # Custom templates
└── volumes/
    └── synapse/               # Synapse data directory
```

## 🔧 Configuration

Based on your backup configuration with these adaptations:
- **Server Name**: 107.189.19.66 (bare IP)
- **Database**: SQLite (for simplicity)
- **Registration**: Enabled without email verification
- **Ports**: Direct exposure (8008, 8448)

## 📋 Management Commands

| Command | Description |
|---------|-------------|
| `./manage.sh start` | Start all services |
| `./manage.sh stop` | Stop all services |
| `./manage.sh restart` | Restart services |
| `./manage.sh logs` | View Synapse logs |
| `./manage.sh status` | Show service status |
| `./manage.sh create-admin` | Create admin user |
| `./manage.sh shell` | Open shell in container |
| `./manage.sh clean` | Clean all data (destructive) |

## 🛠️ First Time Setup

1. **Deploy**: `./deploy.sh`
2. **Wait**: Let services start (about 30 seconds)
3. **Create Admin**: `./manage.sh create-admin`
4. **Test**: Visit http://107.189.19.66:8008

## 🔍 Troubleshooting

### Check logs
```bash
./manage.sh logs
```

### Check status
```bash
./manage.sh status
```

### Restart if needed
```bash
./manage.sh restart
```

### Clean restart
```bash
./manage.sh stop
./deploy.sh
```

## 🔐 Security Notes

- This is a simplified setup for testing
- Enable HTTPS for production use
- Configure proper firewall rules
- Change default passwords
- Disable registration after creating users

## 📊 Monitoring

Check service health:
```bash
curl http://107.189.19.66:8008/health
```

View detailed status:
```bash
./manage.sh status
```
