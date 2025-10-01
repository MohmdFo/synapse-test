# 🚀 Synapse Matrix Server - Quick Deployment Guide

This directory contains a **simplified backup-based deployment** for Synapse Matrix server on **107.189.19.66**.

## 🛠️ Fixed Issues

✅ **Resolved deployment errors:**
- Fixed "Unknown execution mode 'generate-keys'" → Now uses correct `generate` command
- Fixed "Permission denied" for log files → Now uses console logging  
- Added proper UID 991 permission handling for Synapse user

## ⚡ Quick Start

On your server **107.189.19.66**, run:

```bash
# Pull latest fixes
git pull origin main

# Option 1: Run the fixed deployment script
./deploy.sh

# Option 2: If you still have issues, run the quick fix first
./quick-fix.sh
./deploy.sh
```

## 📁 Key Files

- **`deploy.sh`** - Main deployment script (fixed)
- **`quick-fix.sh`** - Troubleshooting script for permission issues
- **`manage.sh`** - Service management (start/stop/logs)
- **`synapse/homeserver.yaml`** - Simplified configuration with console logging
- **`docker-compose.yml`** - Single container setup (no PostgreSQL complexity)

## 🌐 Access Points

After deployment:
- **Web Interface**: http://107.189.19.66:8008
- **Federation**: https://107.189.19.66:8448
- **Server Name**: `107.189.19.66`

## 👤 Create Admin User

```bash
./manage.sh create-admin
# Follow prompts to create your admin account
```

## 🔧 Management Commands

```bash
./manage.sh logs          # View container logs
./manage.sh stop          # Stop services
./manage.sh restart       # Restart services  
./manage.sh create-admin   # Create admin user
```

## 📊 Check Status

```bash
docker-compose ps         # Service status
docker-compose logs -f    # Live logs
```

---

**Note:** This deployment uses SQLite (simple) instead of PostgreSQL (complex) for reliability. All configuration issues have been resolved in the latest commit.
