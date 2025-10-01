# Synapse Independent Deployment

This directory contains a **completely independent** Synapse deployment that doesn't require the Synapse source code repository. It uses pre-built Docker images from Docker Hub.

## 🚀 Quick Start

### 1. Copy this directory to your server
```bash
# Copy the entire synapse-deployment directory to your server
scp -r synapse-deployment/ root@107.189.19.66:/root/
```

### 2. SSH to your server and deploy
```bash
ssh root@107.189.19.66
cd synapse-deployment
chmod +x *.sh
sudo ./deploy.sh
```

## 📁 Directory Structure

```
synapse-deployment/
├── .env                          # Environment configuration
├── docker-compose.yml            # Simple deployment (recommended)
├── docker-compose.workers.yml    # Worker-based deployment (high load)
├── deploy.sh                     # Main deployment script
├── generate-config.sh             # Homeserver config generator
├── generate-workers.sh            # Worker config generator
├── management.sh                  # Management commands
├── nginx.conf                     # Nginx reverse proxy config
├── backup.sh                      # Backup script
└── README.md                      # This file
```

## 🔧 Deployment Options

### Option 1: Simple Deployment (Recommended)
```bash
./deploy.sh
```
Uses `docker-compose.yml` - single Synapse instance with PostgreSQL and Redis.

### Option 2: Worker-Based Deployment (High Load)
```bash
# Generate worker configs first
./generate-workers.sh /opt/synapse/data

# Deploy with workers
docker-compose -f docker-compose.workers.yml up -d
```

## 📋 Key Features

### ✅ **Completely Independent**
- No dependency on Synapse source code
- Uses official `matrixdotorg/synapse:latest` images
- Self-contained configuration generation

### ✅ **Custom Configuration Generation**
- Automatically generates `homeserver.yaml` for your IP
- Creates proper signing keys
- Configures PostgreSQL and Redis
- Sets up logging configuration

### ✅ **Production Ready**
- PostgreSQL database (not SQLite)
- Redis caching
- Health checks for all services
- Proper file permissions and security

### ✅ **Scalable**
- Worker support for high-load deployments
- Load balancer ready (nginx config included)
- Horizontal scaling capability

## 🌐 Access Information

After deployment:
- **Synapse Web**: http://107.189.19.66:8008
- **Matrix Client Connection**: `107.189.19.66:8008`
- **Federation Port**: `107.189.19.66:8448`

## 👤 User Management

### Create Admin User
```bash
docker-compose exec synapse register_new_matrix_user -c /data/homeserver.yaml -a http://localhost:8008
```

### Matrix Client Setup
- **Homeserver**: `http://107.189.19.66:8008`
- **Username**: `@yourusername:107.189.19.66`

## 🔧 Management Commands

```bash
# Service management
docker-compose ps                    # Check status
docker-compose logs -f synapse       # View logs
docker-compose restart synapse       # Restart service
docker-compose down                  # Stop all services
docker-compose pull && docker-compose up -d  # Update

# Database backup
./backup.sh

# Generate new worker configs
./generate-workers.sh /opt/synapse/data
```

## 📊 Monitoring

### Health Checks
```bash
# Check service health
curl http://107.189.19.66:8008/health

# Check all containers
docker-compose ps
```

### Logs
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs synapse
docker-compose logs db
docker-compose logs redis
```

## 🔒 Security Configuration

The deployment includes:
- Strong random passwords
- Proper file permissions (991:991)
- Rate limiting configured
- Registration shared secret
- Secure Redis password protection

### Post-Deployment Security
1. **Change passwords** in `.env` file
2. **Disable registration** after creating admin user:
   ```yaml
   # In /opt/synapse/data/homeserver.yaml
   enable_registration: false
   ```
3. **Set up SSL/TLS** for production
4. **Configure firewall** rules

## 🚀 Performance Tuning

### For High Load (Use Workers)
```bash
# Generate worker configs
./generate-workers.sh /opt/synapse/data

# Deploy workers
docker-compose -f docker-compose.workers.yml up -d
```

Workers included:
- **Generic Worker**: Handles client API requests
- **Federation Sender**: Handles outbound federation
- **Media Repository**: Handles media uploads/downloads

## 🔄 Updates

```bash
# Update to latest Synapse version
docker-compose pull
docker-compose up -d
```

## 🆘 Troubleshooting

### Common Issues
1. **Permission errors**: Check `/opt/synapse` ownership (should be 991:991)
2. **Port conflicts**: Ensure ports 8008, 8448 are available
3. **Database connection**: Check PostgreSQL logs

### Reset Deployment
```bash
docker-compose down -v
rm -rf /opt/synapse/*
./deploy.sh
```

## 📝 Configuration Files

### Generated Automatically
- `/opt/synapse/data/homeserver.yaml` - Main Synapse config
- `/opt/synapse/data/log.config` - Logging configuration
- `/opt/synapse/data/signing.key` - Server signing key
- `/opt/synapse/data/workers/*.yaml` - Worker configurations (if using workers)

### Customizable
- `.env` - Environment variables
- `docker-compose.yml` - Service definitions
- `nginx.conf` - Reverse proxy configuration

This deployment is **production-ready** and **completely independent** of the Synapse source code repository! 🎉
