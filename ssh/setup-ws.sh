#!/bin/bash

# Install and Setup WebSocket-SSH

# Install dependencies
echo "Installing Websockify..."
apt-get install -y websockify
if ! command -v websockify &> /dev/null; then
    apt-get install -y python3-pip
    pip3 install websockify --break-system-packages 2>/dev/null || pip3 install websockify
fi

# Determine executable path
WS_BIN=$(command -v websockify)
if [ -z "$WS_BIN" ]; then
    WS_EXEC="/usr/bin/python3 -m websockify"
else
    WS_EXEC="$WS_BIN"
fi

# Create service for WS-SSH (Port 700 -> Port 22)
cat > /etc/systemd/system/ws-ssh.service << EOF
[Unit]
Description=WebSocket SSH Bridge
Documentation=https://github.com/novnc/websockify
After=network.target

[Service]
Type=simple
User=root
ExecStart=$WS_EXEC 700 127.0.0.1:22
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF

# Reload and start
systemctl daemon-reload
systemctl enable ws-ssh
systemctl restart ws-ssh

echo "WebSocket-SSH (700 -> 22) installed and started."
