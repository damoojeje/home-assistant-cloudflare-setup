# **Self-Hosted Smart Home with Home Assistant & Cloudflare**

## **Overview**

This project demonstrates how to set up a **secure, self-hosted smart home environment** using **Home Assistant**, **Cloudflare Tunnel**, and **Zero Trust authentication**. The setup allows remote access to your home automation system **without exposing any ports** to the internet, ensuring enhanced security.

### **Key Features**

✅ Secure **Home Assistant** deployment in Docker\
✅ **Zigbee2MQTT** for managing smart devices\
✅ **Node-RED** for automation workflows\
✅ **Portainer** for managing Docker containers\
✅ **File Browser** for remote file management\
✅ **Web Console (Cockpit)** for system monitoring\
✅ **Cloudflare Tunnel & Zero Trust** for **secure remote access**\
✅ **Nginx Proxy Manager** for domain and SSL management

---

## **Installation**

### **1. Prerequisites**

- **Ubuntu 22.04+** with **Docker & Docker Compose installed**
- **Cloudflare account** with a domain configured
- **Static local IP assigned to the server**

### **2. Install Docker & Docker Compose**

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose ufw
sudo systemctl enable --now docker
```

### **3. Deploy Home Assistant & Zigbee2MQTT**

```bash
mkdir -p ~/homeassistant ~/zigbee2mqtt

# Home Assistant
sudo docker run -d --name homeassistant --restart=always --network=host -v ~/homeassistant:/config homeassistant/home-assistant

# Zigbee2MQTT
sudo docker run -d --name zigbee2mqtt --restart=always -p 8080:8080 -v ~/zigbee2mqtt:/app/data koenkk/zigbee2mqtt
```

### **4. Configure Cloudflare Tunnel for Secure Access**

```bash
cloudflared tunnel login
cloudflared tunnel create home-assistant
```

Then, configure the **Cloudflare Tunnel settings** to route traffic securely to Home Assistant, Node-RED, Portainer, and other services.

### **5. Deploy Nginx Proxy Manager**

```bash
mkdir ~/nginx-proxy-manager && cd ~/nginx-proxy-manager
nano docker-compose.yml
```

**Add the following:**

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

Then run:

```bash
docker-compose up -d
```

### **6. Configure Cloudflare Zero Trust Authentication**

- Enable **Cloudflare Zero Trust Access** to require login before accessing Home Assistant.
- Set up **Access Policies** to prevent unauthorized access.

---

## **Troubleshooting & Common Issues**

### **❌ Issue: 502 Bad Gateway Errors**

✅ **Solution:** Ensure Cloudflare SSL settings are set to **Full** (not Full Strict) and proxy settings in Nginx Proxy Manager use HTTP instead of HTTPS.

### **❌ Issue: Web Console Not Loading in Home Assistant**

✅ **Solution:** Modify **Nginx Proxy Manager settings** to allow iFrame embedding:

```yaml
proxy_hide_header X-Frame-Options;
add_header X-Frame-Options SAMEORIGIN;
add_header Content-Security-Policy "frame-ancestors 'self' https://ha.example.com";
```

### **❌ Issue: Dynamic IP Breaking Setup**

✅ **Solution:** Assign a **static IP** to the Ubuntu server and configure the router to **reserve the IP**.

---

## **Lessons Learned**

💡 **Cloudflare Zero Trust eliminates the need for open ports.**\
💡 **Docker allows for easy service management & backups.**\
💡 **Proper DNS, SSL, and Proxy settings prevent access issues.**\
💡 **Using Nginx Proxy Manager simplifies domain handling.**

---


