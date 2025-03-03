# 🚀 Home Assistant Secure Setup - Initial Release (v1.0.0)

## **🔹 Overview**
This release provides a **fully automated, secure, and scalable** Home Assistant setup using **Docker, Cloudflare Tunnel, and Zero Trust authentication**. The deployment eliminates the need for port forwarding, ensuring a safer smart home environment.

### **📌 Key Features**
- 🏠 **Home Assistant in Docker** for smart home automation
- 📡 **Zigbee2MQTT** for Zigbee device management
- 🔄 **Node-RED** for automation workflows
- 🛠 **Portainer** for Docker container management
- 📂 **File Browser** for remote file access
- 🖥 **Web Console (Cockpit)** for system monitoring
- 🔐 **Cloudflare Tunnel** for secure remote access without exposed ports
- 🌐 **Nginx Proxy Manager (NPM)** for domain management & SSL setup

---

## **🛠 Installation Guide**
### **1️⃣ Prerequisites**
- **Ubuntu 22.04+ server** with **Docker & Docker Compose installed**
- **Cloudflare account** with a configured domain
- **Static IP assigned to your server**
- **Git installed** (`sudo apt install git -y`)

### **2️⃣ Clone the Repository**
```bash
git clone https://github.com/YOUR_USERNAME/home-assistant-cloudflare-setup.git
cd home-assistant-cloudflare-setup
```

### **3️⃣ Grant Execution Permissions**
```bash
chmod +x setup.sh
```

### **4️⃣ Run the Setup Script**
```bash
./setup.sh
```

### **5️⃣ Deploy Services Manually (If Needed)**
```bash
docker-compose up -d
```

---

## **🔧 Troubleshooting & Common Issues**

### **❌ 502 Bad Gateway Errors**
✅ **Solution:** Ensure Cloudflare SSL is set to **Full** and proxy settings in Nginx Proxy Manager use HTTP.

### **❌ Web Console Not Loading in Home Assistant**
✅ **Solution:** Modify **Nginx Proxy Manager settings** to allow iFrame embedding:
```yaml
proxy_hide_header X-Frame-Options;
add_header X-Frame-Options SAMEORIGIN;
add_header Content-Security-Policy "frame-ancestors 'self' https://ha.example.com";
```

### **❌ Dynamic IP Breaking Setup**
✅ **Solution:** Assign a **static IP** to the Ubuntu server and configure your router to reserve the IP.

---

## **📅 Future Plans**
🚀 Automate backups for Home Assistant & Zigbee2MQTT  
🚀 Integrate smart home automation with AI  
🚀 Add support for additional smart home integrations  

---

## **📢 Get Involved**
📌 **Star this repo** if you find it useful! ⭐  
📌 **Contribute improvements via pull requests**  
📌 **Follow for updates** [GitHub Profile Link]  
📌 **More automation projects on LinkedIn!** [LinkedIn Profile Link]  

---

### **🎉 Thank you for using this setup! Your smart home just got more secure.**


