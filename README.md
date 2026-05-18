# 🚀 Node.js Backend Auto Deployment (Linux VM)

This project includes a fully automated setup script that installs:

- Node.js (LTS)
- Nginx reverse proxy
- Systemd service (auto start/restart)
- Git-based deployment
- Public IP / domain configuration

---
## 🤖 For NODE.JS AGENT (recommended):
### 🔥 WHAT YOU MUST CHANGE

  Replace this line:
  
    SERVER_IP = "YOUR_SERVER_PUBLIC_IP"

# ⚡ One Command Setup

    chmod +x setup.sh
    sudo ./setup.sh
  
## 🤖 After Setup System Check
  # ⚡ Check Status online:
    systemctl start vm-monitor
  # ⚡ For Logs:
    journalctl -u vm-monitor -f
