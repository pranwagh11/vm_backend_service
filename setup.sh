#!/bin/bash

set -e

echo "=============================="
echo "🚀 Node Backend Auto Setup"
echo "=============================="

# ================= CONFIG =================
REPO_URL="https://github.com/your-user/your-backend.git"
APP_NAME="node-backend"
APP_DIR="/var/www/node-backend"
PORT=3000
ENTRY_FILE="index.js"
# =========================================

echo ""
echo "🌐 Enter your domain or public IP (press Enter to auto-detect):"
read DOMAIN_OR_IP

if [ -z "$DOMAIN_OR_IP" ]; then
  DOMAIN_OR_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip || hostname -I | awk '{print $1}')
fi

echo "✅ Using: $DOMAIN_OR_IP"

echo ""
echo "📦 Updating system..."
sudo apt update && sudo apt upgrade -y

echo ""
echo "📦 Installing dependencies..."
sudo apt install -y nginx git curl build-essential

echo ""
echo "🟢 Installing Node.js (LTS)..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

echo "📌 Node version:"
node -v
npm -v

echo ""
echo "📁 Cloning backend..."
sudo rm -rf $APP_DIR
sudo git clone $REPO_URL $APP_DIR

cd $APP_DIR

echo ""
echo "📦 Installing npm packages..."
sudo npm install

NODE_PATH=$(which node)

echo ""
echo "⚙️ Creating systemd service..."

sudo bash -c "cat > /etc/systemd/system/$APP_NAME.service" <<EOL
[Unit]
Description=Node Backend Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$APP_DIR
ExecStart=$NODE_PATH $ENTRY_FILE
Restart=always
Environment=NODE_ENV=production
Environment=PORT=$PORT

[Install]
WantedBy=multi-user.target
EOL

echo ""
echo "🔄 Starting backend service..."
sudo systemctl daemon-reload
sudo systemctl enable $APP_NAME
sudo systemctl restart $APP_NAME

echo ""
echo "🌐 Configuring Nginx reverse proxy..."

sudo bash -c "cat > /etc/nginx/sites-available/$APP_NAME" <<EOL
server {
    listen 80;
    server_name $DOMAIN_OR_IP;

    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;

        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

sudo ln -sf /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t
sudo systemctl restart nginx

echo ""
echo "=============================="
echo "✅ SETUP COMPLETE!"
echo "=============================="
echo "🌍 Access your backend:"
echo "👉 http://$DOMAIN_OR_IP"
echo ""
echo "⚙️ Service:"
echo "sudo systemctl status $APP_NAME"
echo "=============================="
