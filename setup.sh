#!/bin/bash

# Exit script if any command fails
set -e

echo "🔧 Starting Home Assistant & Cloudflare Setup..."

# -----------------------------
# 🟢 Step 1: System Update & Install Dependencies
# -----------------------------
echo "📦 Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose ufw curl

# Enable Docker service
sudo systemctl enable --now docker

# -----------------------------
# 🟢 Step 2: Deploy Home Assistant & Zigbee2MQTT
# -----------------------------
echo "🏠 Deploying Home Assistant..."
mkdir -p ~/homeassistant ~/zigbee2mqtt

docker run -d --name homeassistant --restart=always --network=host \
  -v ~/homeassistant:/config homeassistant/home-assistant:latest

echo "🛠️ Deploying Zigbee2MQTT..."
docker run -d --name zigbee2mqtt --restart=always -p 8080:8080 \
  -v ~/zigbee2mqtt:/app/data koenkk/zigbee2mqtt:latest

# -----------------------------
# 🟢 Step 3: Deploy Nginx Proxy Manager
# -----------------------------
echo "🌐 Deploying Nginx Proxy Manager..."
mkdir -p ~/nginx-proxy-manager && cd ~/nginx-proxy-manager

cat <<EOF > docker-compose.yml
version: '3.8'
services:
  npm:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: nginx-proxy-manager
    restart: unless-stopped
    ports:
      - "80:80"
      - "81:81"
      - "443:443"
    volumes:
      - npm_data:/data
      - npm_data:/etc/letsencrypt
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Chicago
volumes:
  npm_data:
EOF

docker-compose up -d

# -----------------------------
# 🟢 Step 4: Configure Cloudflare Tunnel
# -----------------------------
echo "☁️ Setting up Cloudflare Tunnel..."
cloudflared tunnel login
cloudflared tunnel create home-assistant

mkdir -p ~/.cloudflared
read -p "Enter your Cloudflare Tunnel ID: " CF_TUNNEL_ID
read -p "Enter your Home Assistant domain (e.g., ha.example.com): " HA_DOMAIN

cat <<EOF > ~/.cloudflared/config.yml
tunnel: $CF_TUNNEL_ID
credentials-file: /home/$USER/.cloudflared/$CF_TUNNEL_ID.json

ingress:
  - hostname: $HA_DOMAIN
    service: http://localhost:8123
    originRequest:
      noTLSVerify: true
  - service: http_status:404
EOF

# -----------------------------
# 🟢 Step 5: Start Cloudflare Tunnel
# -----------------------------
echo "🚀 Starting Cloudflare Tunnel..."
cloudflared service install
sudo systemctl enable --now cloudflared

# -----------------------------
# 🎉 Setup Complete!
# -----------------------------
echo "✅ Setup complete! Access Home Assistant at: https://$HA_DOMAIN"
