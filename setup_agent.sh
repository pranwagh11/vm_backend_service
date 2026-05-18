#!/bin/bash

# Update system
apt update -y
apt install -y nodejs npm

# Create agent folder
mkdir -p /home/ubuntu/agent
cd /home/ubuntu/agent

# Create package.json
npm init -y

# Install dependencies
npm install ws os axios

# Create agent.js
cat << 'EOF' > agent.js

const WebSocket = require("ws");
const os = require("os");
const axios = require("axios");

const SERVER_IP = "YOUR_SERVER_PUBLIC_IP";
const WS_URL = `ws://${SERVER_IP}:8080`;

const TOKEN = "secret123";
const HOSTNAME = os.hostname();

function getCPU() {
    return os.loadavg()[0];
}

function getMemory() {
    const total = os.totalmem();
    const free = os.freemem();
    return ((total - free) / total) * 100;
}

async function getPublicIP() {
    try {
        const res = await axios.get("https://api.ipify.org?format=json");
        return res.data.ip;
    } catch {
        return "unknown";
    }
}

function collectMetrics(publicIP) {
    return {
        hostname: HOSTNAME,
        public_ip: publicIP,
        cpu_load: getCPU(),
        memory_percent: getMemory(),
        load_avg: os.loadavg(),
        uptime: os.uptime()
    };
}

async function start() {
    const publicIP = await getPublicIP();

    const ws = new WebSocket(WS_URL);

    ws.on("open", () => {
        console.log("Connected");

        ws.send(JSON.stringify({
            type: "auth",
            token: TOKEN,
            hostname: HOSTNAME
        }));

        setInterval(() => {
            ws.send(JSON.stringify({
                type: "metrics",
                data: collectMetrics(publicIP)
            }));
        }, 5000);
    });

    ws.on("close", () => {
        console.log("Disconnected, retrying...");
        setTimeout(start, 3000);
    });

    ws.on("error", (err) => {
        console.log("Error:", err.message);
    });
}

start();

EOF

# Fix permissions
chown -R ubuntu:ubuntu /home/ubuntu/agent

# Create systemd service
cat << 'EOF' > /etc/systemd/system/vm-agent.service

[Unit]
Description=VM Agent
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/agent
ExecStart=/usr/bin/node /home/ubuntu/agent/agent.js
Restart=always

[Install]
WantedBy=multi-user.target

EOF

# Enable service
systemctl daemon-reload
systemctl enable vm-agent
systemctl start vm-agent
