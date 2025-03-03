# home-assistant-cloudflare-setup
A secure Home Assistant setup with Cloudflare Tunnel &amp; Zero Trust authentication.
#!/bin/bash

# Automated Smart Home Setup Script
# This script sets up Home Assistant, Cloudflare Tunnel, and related services on an Ubuntu server.
# It prompts the user for key details to customize the setup.

read -p "Enter your Ubuntu static IP (e.g., 192.168.X.X): " UBUNTU_IP
read -p "Enter your domain name (e.g., example.com): " DOMAIN_NAME
read -p "Enter your Cloudflare Tunnel ID: " TUNNEL_ID

# Update & Install Dependencies
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose ufw
sudo systemctl enable --now docker

# Set Up Firewall
echo "Configuring firewall..."
sudo ufw allow from 192.168.0.0/24 to any port 443
sudo ufw enable

# Install Portainer
echo "Installing Portainer..."
docker volume create portainer_data
docker run -d --name=portainer --restart=always -p 9443:9443 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

# Install Home Assistant
echo "Installing Home Assistant..."
mkdir -p ~/homeassistant
docker run -d --name homeassistant --restart=always --network=host -v ~/homeassistant:/config homeassistant/home-assistant

# Install Zigbee2MQTT
echo "Installing Zigbee2MQTT..."
mkdir -p ~/zigbee2mqtt
docker run -d --name zigbee2mqtt --restart=always -p 8080:8080 -v ~/zigbee2mqtt:/app/data koenkk/zigbee2mqtt

# Install Node-RED
echo "Installing Node-RED..."
docker run -d --name nodered --restart=always -p 1880:1880 nodered/node-red

# Install Nginx Proxy Manager
echo "Installing Nginx Proxy Manager..."
mkdir ~/nginx-proxy-manager && cd ~/nginx-proxy-manager
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

# Install Cloudflare Tunnel
echo "Installing Cloudflare Tunnel..."
curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/
cloudflared tunnel login
cloudflared tunnel create home-assistant

# Configure Cloudflare Tunnel
echo "Configuring Cloudflare Tunnel..."
mkdir -p ~/.cloudflared
cat <<EOF > ~/.cloudflared/config.yml
tunnel: $TUNNEL_ID
credentials-file: /home/$USER/.cloudflared/$TUNNEL_ID.json

ingress:
  - hostname: ha.$DOMAIN_NAME
    service: http://$UBUNTU_IP:8123
    originRequest:
      noTLSVerify: true
  - hostname: mqtt.$DOMAIN_NAME
    service: http://$UBUNTU_IP:8080
    originRequest:
      noTLSVerify: true
  - hostname: nodered.$DOMAIN_NAME
    service: http://$UBUNTU_IP:1880
    originRequest:
      noTLSVerify: true
  - hostname: portainer.$DOMAIN_NAME
    service: http://$UBUNTU_IP:9443
    originRequest:
      noTLSVerify: true
  - hostname: webconsole.$DOMAIN_NAME
    service: http://$UBUNTU_IP:9090
    originRequest:
      noTLSVerify: true
  - service: http_status:404
EOF

# Start Cloudflare Tunnel
cloudflared tunnel run home-assistant &

echo "Setup complete! Access your services at the configured domain names."

# Ensure the script has execute permission
chmod +x setup.sh

