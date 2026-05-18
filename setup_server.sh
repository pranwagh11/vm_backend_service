#!/bin/bash

set -e

# Update system
apt update -y
apt upgrade -y

# Install Node.js + npm
apt install -y nodejs npm

# Create server folder
mkdir -p /home/ubuntu/monitor-backend
cd /home/ubuntu/monitor-backend

# Initialize project
npm init -y

# Install dependencies
npm install express ws

# Create server.js
cat << 'EOF' > server.js

const express = require("express");
const http = require("http");
const WebSocket = require("ws");

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const PORT = 8080;

// In-memory storage
const vmData = {};

app.get("/", (req, res) => {
    res.send("VM Monitoring Server Running");
});

app.get("/metrics", (req, res) => {
    res.json(vmData);
});

wss.on("connection", (ws) => {

    let vmId = null;

    ws.on("message", (msg) => {
        try {
            const data = JSON.parse(msg);

            // AUTH
            if (data.type === "auth") {

                if (data.token !== "secret123") {
                    ws.close();
                    return;
                }

                vmId = data.hostname;

                console.log("Authenticated:", vmId);
            }

            // METRICS
            if (data.type === "metrics") {

                if (!vmId) return;

                vmData[vmId] = {
                    ...data.data,
                    updatedAt: Date.now()
                };

                console.log("\n===== LIVE METRICS =====");
                console.log(JSON.stringify(vmData, null, 2));
            }

        } catch (err) {
            console.log("Error:", err.message);
        }
    });

    ws.on("close", () => {
        console.log("Disconnected:", vmId);
        delete vmData[vmId];
    });
});

server.listen(8080, "0.0.0.0", () => {
    console.log("Server running on port 8080");
});

EOF

# Fix permissions
chown -R ubuntu:ubuntu /home/ubuntu/monitor-backend

# Create systemd service
cat << 'EOF' > /etc/systemd/system/vm-monitor.service

[Unit]
Description=VM Monitoring Server
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/monitor-backend
ExecStart=/usr/bin/node /home/ubuntu/monitor-backend/server.js
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target

EOF

# Enable and start service
systemctl daemon-reload
systemctl enable vm-monitor
systemctl start vm-monitor
