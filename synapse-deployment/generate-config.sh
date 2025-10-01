#!/bin/bash

# Generate Synapse Configuration Script
# This script generates a complete homeserver.yaml for your specific needs

set -e

SERVER_IP="$1"
CONFIG_DIR="$2"

if [ -z "$SERVER_IP" ] || [ -z "$CONFIG_DIR" ]; then
    echo "Usage: $0 <server_ip> <config_dir>"
    exit 1
fi

echo "📝 Generating homeserver.yaml for $SERVER_IP..."

# Create signing key
echo "🔑 Generating signing key..."
mkdir -p "$CONFIG_DIR"
SIGNING_KEY_FILE="$CONFIG_DIR/signing.key"

# Generate Synapse-compatible signing key if it doesn't exist
if [ ! -f "$SIGNING_KEY_FILE" ]; then
    # Generate a random signing key in the format Synapse expects
    # Synapse uses its own format: "ed25519 <key_id> <base64_encoded_key>"
    KEY_ID=$(openssl rand -hex 8)
    # Generate 32 bytes of random data and base64 encode it
    KEY_DATA=$(openssl rand 32 | base64 -w 0)
    echo "ed25519 a_${KEY_ID} ${KEY_DATA}" > "$SIGNING_KEY_FILE"
    chmod 600 "$SIGNING_KEY_FILE"
fi

# Generate homeserver.yaml
cat > "$CONFIG_DIR/homeserver.yaml" << EOF
# Synapse Configuration for $SERVER_IP
# Generated on $(date)

# Server configuration
server_name: "$SERVER_IP"
public_baseurl: "http://$SERVER_IP:8008"
pid_file: /data/homeserver.pid

# Listeners
listeners:
  - port: 8008
    type: http
    tls: false
    bind_addresses: ['::1', '127.0.0.1', '0.0.0.0']
    resources:
      - names: [client, federation]
        compress: false

# Database configuration (PostgreSQL)
database:
  name: psycopg2
  args:
    user: synapse_user
    password: SynapseSecure2024!
    database: synapse
    host: db
    port: 5432
    cp_min: 5
    cp_max: 10

# Redis configuration
redis:
  enabled: true
  host: redis
  port: 6379
  password: RedisSecure2024!

# Registration and user management
enable_registration: true
registration_shared_secret: "YourRegistrationSecret2024!"
enable_registration_without_verification: true

# Require email for registration (disabled for initial setup)
# registrations_require_3pid:
#   - email

# Allow guest access
allow_guest_access: false

# Media store configuration
media_store_path: /data/media_store
max_upload_size: 100M
max_image_pixels: 32M

# URL previews
url_preview_enabled: true
url_preview_ip_range_blacklist:
  - '127.0.0.0/8'
  - '10.0.0.0/8'
  - '172.16.0.0/12'
  - '192.168.0.0/16'
  - '100.64.0.0/10'
  - '169.254.0.0/16'
  - '::1/128'
  - 'fe80::/64'
  - 'fc00::/7'

# Rate limiting
rc_message:
  per_second: 0.2
  burst_count: 10

rc_registration:
  per_second: 0.17
  burst_count: 3

rc_login:
  address:
    per_second: 0.17
    burst_count: 3
  account:
    per_second: 0.17
    burst_count: 3
  failed_attempts:
    per_second: 0.17
    burst_count: 3

# Federation
federation_domain_whitelist: []
allow_public_rooms_without_auth: false
allow_public_rooms_over_federation: false

# Security
form_secret: "$(openssl rand -hex 32)"
macaroon_secret_key: "$(openssl rand -hex 32)"

# Signing key
signing_key_path: "/data/signing.key"

# Trusted key servers
trusted_key_servers:
  - server_name: "matrix.org"

# TURN server (optional - uncomment and configure if needed)
# turn_uris: [ "turn:your.turn.server:3478?transport=udp", "turn:your.turn.server:3478?transport=tcp" ]
# turn_shared_secret: "YOUR_TURN_SECRET"
# turn_user_lifetime: 86400000
# turn_allow_guests: True

# Statistics and metrics
report_stats: false
enable_metrics: false

# Logging configuration
log_config: "/data/log.config"

# Push notifications
push:
  include_content: true

# Presence
use_presence: true
presence:
  enabled: true

# Admin contact
admin_contact: 'mailto:admin@$SERVER_IP'

# User directory
user_directory:
  enabled: true
  search_all_users: false
  prefer_local_users: true

# Room list settings
room_list_publication_rules:
  - user_id: "*"
    alias: "*"
    room_id: "*"
    action: allow

# Experimental features
experimental_features:
  # Enable faster room joins
  faster_joins: true
  
# Email configuration (optional - configure for password reset, notifications)
# email:
#   smtp_host: localhost
#   smtp_port: 25
#   smtp_user: ""
#   smtp_pass: ""
#   force_tls: false
#   require_transport_security: false
#   enable_tls: false
#   notif_from: "Your Friendly %(app)s Server <noreply@$SERVER_IP>"
#   app_name: Matrix
#   enable_notifs: false
#   notif_for_new_users: false

# Password configuration
password_config:
  enabled: true
  localdb_enabled: true
  pepper: "$(openssl rand -hex 32)"

# User consent
# user_consent:
#   template_dir: res/templates/privacy
#   version: 1.0

# Server notices
# server_notices:
#   system_mxid_localpart: notices
#   system_mxid_display_name: "Server Notices"
#   system_mxid_avatar_url: "mxc://server.com/oumMVlgDnLYFaPVkExemINVg"
#   room_name: "Server Notices"

# Auto-join rooms (optional)
# auto_join_rooms:
#   - "#general:$SERVER_IP"

EOF

# Generate logging configuration
cat > "$CONFIG_DIR/log.config" << EOF
version: 1

formatters:
  precise:
    format: '%(asctime)s - %(name)s - %(lineno)d - %(levelname)s - %(request)s - %(message)s'

handlers:
  file:
    class: logging.handlers.TimedRotatingFileHandler
    formatter: precise
    filename: /data/homeserver.log
    when: midnight
    backupCount: 3  # Does not include the current log file.
    encoding: utf8

  # Default to buffering writes to the log file for efficiency. This means that
  # there will be a delay for INFO/DEBUG logs to get written, but WARNING/ERROR
  # logs will still be flushed immediately.
  buffer:
    class: logging.handlers.MemoryHandler
    target: file
    # The capacity is the number of log lines that are buffered before
    # being written to disk. Increasing this will lead to better
    # performance, at the expensive of it taking longer for log lines
    # to be written to disk.
    capacity: 10
    flushLevel: 30  # Flush for WARNING logs as well

  console:
    class: logging.StreamHandler
    formatter: precise

loggers:
    synapse.storage.SQL:
        # beware: increasing this to DEBUG will make synapse log sensitive
        # information such as access tokens.
        level: INFO

root:
    level: INFO
    handlers: [buffer, console]

disable_existing_loggers: false
EOF

# Set proper permissions
chown -R 991:991 "$CONFIG_DIR"
chmod 600 "$CONFIG_DIR/homeserver.yaml"
chmod 600 "$CONFIG_DIR/log.config"
chmod 600 "$CONFIG_DIR/signing.key"

echo "✅ Configuration files generated successfully!"
echo "📁 Files created:"
echo "   - $CONFIG_DIR/homeserver.yaml"
echo "   - $CONFIG_DIR/log.config"
echo "   - $CONFIG_DIR/signing.key"
