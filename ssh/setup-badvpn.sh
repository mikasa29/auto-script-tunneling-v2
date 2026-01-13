#!/bin/bash

# Setup UDP Custom / BadVPN (Compile from Source for Stability)

echo "Preparing to build BadVPN-UDPGW..."

# Install build dependencies if missing
apt-get install -y cmake build-essential git

# Create temporary build directory
mkdir -p /tmp/badvpn-build
cd /tmp/badvpn-build

# Download source code
echo "Downloading source code..."
rm -rf badvpn
git clone https://github.com/ambrop72/badvpn.git

# Build
echo "Compiling BadVPN (This may take a minute)..."
cd badvpn
mkdir build
cd build
cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
make

# Install binary
if [ -f "udpgw/badvpn-udpgw" ]; then
    echo "Compilation successful!"
    cp udpgw/badvpn-udpgw /usr/bin/badvpn-udpgw
    chmod +x /usr/bin/badvpn-udpgw
else
    echo "Compilation failed! Falling back to pre-compiled binary..."
    # Fallback content if needed, but compilation usually works
    wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/ssh/badvpn-udpgw64"
    chmod +x /usr/bin/badvpn-udpgw
fi

# Clean up
cd /root
rm -rf /tmp/badvpn-build

# Create BadVPN Service
cat > /etc/systemd/system/badvpn.service << EOF
[Unit]
Description=BadVPN UDP Gateway
Documentation=https://github.com/ambrop72/badvpn
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable & Start Service
systemctl daemon-reload
systemctl enable badvpn
systemctl start badvpn

echo "BadVPN UDP Gateway installed and running on port 7300"
