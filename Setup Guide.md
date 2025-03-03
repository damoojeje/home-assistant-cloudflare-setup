# **How to Use the Home Assistant Cloudflare Setup Script**

## **Overview**
This guide provides a **step-by-step process** on how to use the **setup script (`setup.sh`)** and the **required YAML configuration file (`config.yml`)** for deploying a secure Home Assistant setup using **Cloudflare Tunnel, Docker, and Nginx Proxy Manager**.

---

## **🛠 Prerequisites**
Before running the script, make sure you have:
✅ **Ubuntu 22.04+ installed** on your home server.  
✅ **Docker & Docker Compose installed** (`sudo apt install docker.io docker-compose -y`).  
✅ **Cloudflare account with a registered domain**.  
✅ **A static IP address assigned to your server**.  
✅ **Git installed** (`sudo apt install git -y`).  
✅ **Cloudflare Tunnel setup in your Cloudflare account**.  

---

## **📌 Step 1: Clone the Repository**
First, download the script and necessary files from GitHub:
```bash
git clone https://github.com/damoojeje/home-assistant-cloudflare-setup.git
cd home-assistant-cloudflare-setup
```

---

## **📌 Step 2: Provide Required Information**
Before running the script, the user must provide some required details. When executed, the script will prompt for:
- **Your Ubuntu static IP** (e.g., `192.168.X.X`)
- **Your domain name** (e.g., `example.com`)
- **Your Cloudflare Tunnel ID** (found in Cloudflare Dashboard)

---

## **📌 Step 3: Make the Script Executable**
To ensure the script can run, grant it execution permissions:
```bash
chmod +x setup.sh
```

---

## **📌 Step 4: Run the Setup Script**
Run the script to install and configure all necessary services:
```bash
./setup.sh
```
This will:
✅ **Install Home Assistant, Zigbee2MQTT, Node-RED, and Portainer**.  
✅ **Deploy Nginx Proxy Manager for domain management**.  
✅ **Set up Cloudflare Tunnel and configure secure access**.  
✅ **Apply firewall rules to protect your system**.  

---

## **📌 Step 5: Configure Cloudflare Tunnel (`config.yml`)**
To ensure Cloudflare Tunnel routes traffic correctly, update the `config.yml` file. Open the file:
```bash
nano ~/.cloudflared/config.yml
```
Modify it to match your setup:
```yaml
tunnel: YOUR_TUNNEL_ID
credentials-file: /home/$USER/.cloudflared/YOUR_TUNNEL_ID.json

ingress:
  - hostname: ha.example.com
    service: http://192.168.X.X:8123
    originRequest:
      noTLSVerify: true
  - hostname: mqtt.example.com
    service: http://192.168.X.X:8080
    originRequest:
      noTLSVerify: true
  - hostname: nodered.example.com
    service: http://192.168.X.X:1880
    originRequest:
      noTLSVerify: true
  - hostname: portainer.example.com
    service: http://192.168.X.X:9443
    originRequest:
      noTLSVerify: true
  - hostname: webconsole.example.com
    service: http://192.168.X.X:9090
    originRequest:
      noTLSVerify: true
  - service: http_status:404
```
Save and exit (`CTRL + X`, then `Y`, then `ENTER`).

Restart Cloudflare Tunnel:
```bash
sudo systemctl restart cloudflared
```

---

## **📌 Step 6: Verify Installation**
Once the script completes:
1️⃣ **Check running containers:**
```bash
docker ps
```
You should see Home Assistant, Zigbee2MQTT, Node-RED, Portainer, and Nginx Proxy Manager running.

2️⃣ **Check Cloudflare Tunnel logs:**
```bash
cloudflared tunnel info home-assistant
```

3️⃣ **Test your domains:**
Try accessing Home Assistant via `https://ha.example.com` (replace with your actual domain).

---

## **📌 Troubleshooting & Common Issues**

### **❌ Issue: 502 Bad Gateway Errors**
✅ **Solution:** Ensure Cloudflare SSL settings are set to **Full** (not Full Strict) and Nginx Proxy Manager is using HTTP.

### **❌ Issue: Web Console Not Loading in Home Assistant**
✅ **Solution:** Modify **Nginx Proxy Manager settings** to allow iFrame embedding:
```yaml
proxy_hide_header X-Frame-Options;
add_header X-Frame-Options SAMEORIGIN;
add_header Content-Security-Policy "frame-ancestors 'self' https://ha.example.com";
```

### **❌ Issue: Dynamic IP Breaking Setup**
✅ **Solution:** Assign a **static IP** to the Ubuntu server and configure your router to **reserve the IP**.

---

## **🎯 Conclusion**
Following this guide, you will have a **fully functional and secure smart home setup** with **Cloudflare Tunnel and Docker**. Your **Home Assistant, Zigbee2MQTT, and Node-RED** instances will be accessible **remotely without exposing ports**.

🚀 **Next Steps:**
- Enable **Cloudflare Zero Trust authentication** for additional security.
- Explore **Home Assistant automation with AI integrations**.
- Set up **automatic backups for Home Assistant & Zigbee2MQTT**.

📌 **For more details, check the full GitHub repository:** [https://github.com/damoojeje/home-assistant-cloudflare-setup](https://github.com/damoojeje/home-assistant-cloudflare-setup)

🎉 **Happy Home Automating!** 🚀


