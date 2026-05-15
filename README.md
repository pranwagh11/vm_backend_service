# 🚀 Node.js Backend Auto Deployment (Linux VM)

This project includes a fully automated setup script that installs:

- Node.js (LTS)
- Nginx reverse proxy
- Systemd service (auto start/restart)
- Git-based deployment
- Public IP / domain configuration

---

## ⚙️ GitHub Download Method

sudo apt update
sudo apt install unzip

```bash
curl -L https://github.com/pranwagh11/vm_backend_service/archive/refs/heads/main.zip -o backend.zip

# ⚡ One Command Setup

unzip backend.zip

cd vm_backend_service-main

```bash
chmod +x setup.sh
sudo ./setup.sh
