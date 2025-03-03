### **Automation Scripts for Home Assistant & Cloudflare Secure Setup**

This document provides a structured list of all necessary automation scripts and configurations used in the project. These files should be uploaded to GitHub for sharing and future replication.

---

## **📂 Recommended Repository Structure**
```
/home-assistant-cloudflare-setup
│── README.md  # Project Overview
│── setup-scripts
│   │── install_docker.sh  # Installs Docker & dependencies
│   │── deploy_homeassistant.sh  # Deploys Home Assistant & Zigbee2MQTT
│   │── deploy_nginx_proxy.sh  # Deploys Nginx Proxy Manager
│   │── configure_cloudflare.sh  # Sets up Cloudflare Tunnel
│── config-files
│   │── configuration.yaml  # Home Assistant Configuration
│   │── cloudflared-config.yml  # Cloudflare Tunnel Settings
│   │── docker-compose.yml  # Nginx Proxy Manager Deployment
│── LICENSE  # Open-source license (optional)
```

---

## **1️⃣ install_docker.sh (Docker & Dependencies Installation)**
```bash
#!/bin/bash
# Install Docker & Docker Compose on Ubuntu
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose ufw
sudo systemctl enable --now docker
```

---

## **2️⃣ deploy_homeassistant.sh (Deploys Home Assistant & Zigbee2MQTT)**
```bash
#!/bin/bash
# Deploy Home Assistant & Zigbee2MQTT
mkdir -p ~/homeassistant ~/zigbee2mqtt

docker run -d --name homeassistant --restart=always --network=host -v ~/homeassistant:/config homeassistant/home-assistant

docker run -d --name zigbee2mqtt --restart=always -p 8080:8080 -v ~/zigbee2mqtt:/app/data koenkk/zigbee2mqtt
```

---

## **3️⃣ deploy_nginx_proxy.sh (Deploys Nginx Proxy Manager)**
```bash
#!/bin/bash
# Deploy Nginx Proxy Manager
docker volume create npm_data
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
```

---

## **4️⃣ configure_cloudflare.sh (Cloudflare Tunnel Setup)**
```bash
#!/bin/bash
# Configure Cloudflare Tunnel
cloudflared tunnel login
cloudflared tunnel create home-assistant

mkdir -p ~/.cloudflared
cat <<EOF > ~/.cloudflared/config.yml
tunnel: YOUR_TUNNEL_ID
credentials-file: /home/$USER/.cloudflared/YOUR_TUNNEL_ID.json

ingress:
  - hostname: ha.example.com
    service: http://192.168.X.X:8123
    originRequest:
      noTLSVerify: true
  - hostname: nodered.example.com
    service: http://192.168.X.X:1880
    originRequest:
      noTLSVerify: true
  - service: http_status:404
EOF
```

---

## **5️⃣ configuration.yaml (Home Assistant Config File)**
```yaml
default_config:
frontend:
  themes: !include_dir_merge_named themes

http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 192.168.X.X
    - 127.0.0.1
  cors_allowed_origins:
    - "*"

panel_iframe:
  portainer:
    title: "Portainer"
    icon: "mdi:docker"
    url: "https://portainer.example.com"
  nodered:
    title: "Node-RED"
    icon: "mdi:sitemap"
    url: "https://nodered.example.com"
```

---

## **6️⃣ cloudflared-config.yml (Cloudflare Tunnel Config)**
```yaml
tunnel: YOUR_TUNNEL_ID
credentials-file: /home/$USER/.cloudflared/YOUR_TUNNEL_ID.json

ingress:
  - hostname: ha.example.com
    service: http://192.168.X.X:8123
    originRequest:
      noTLSVerify: true
  - service: http_status:404
```

---

## **7️⃣ docker-compose.yml (Nginx Proxy Manager Deployment)**
```yaml
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
```

