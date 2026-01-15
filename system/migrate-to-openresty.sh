#!/bin/bash

# Migration Script: Nginx Standard → OpenResty
# This safely migrates from standard Nginx to OpenResty

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}     Nginx → OpenResty Migration Script       ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} Please run as root"
    exit 1
fi

# Confirmation
echo -e "${YELLOW}WARNING:${NC} This will replace Nginx with OpenResty"
echo ""
read -p "Continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Migration cancelled."
    exit 0
fi

# Step 1: Backup existing Nginx config
echo ""
echo -e "${CYAN}[Step 1/7]${NC} Backing up Nginx configuration..."
mkdir -p /root/nginx-backup
cp -r /etc/nginx /root/nginx-backup/
echo -e "${GREEN}✓${NC} Backup saved to /root/nginx-backup/"

# Step 2: Stop Nginx
echo ""
echo -e "${CYAN}[Step 2/7]${NC} Stopping Nginx..."
systemctl stop nginx
systemctl disable nginx
echo -e "${GREEN}✓${NC} Nginx stopped and disabled"

# Step 3: Install OpenResty
echo ""
echo -e "${CYAN}[Step 3/7]${NC} Installing OpenResty..."
bash /usr/local/sbin/tunneling/install-openresty.sh

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} OpenResty installation failed!"
    echo "Rolling back..."
    systemctl enable nginx
    systemctl start nginx
    exit 1
fi

# Step 4: Generate OpenResty config
echo ""
echo -e "${CYAN}[Step 4/7]${NC} Generating OpenResty configuration..."
bash /usr/local/sbin/tunneling/generate-openresty-config.sh

# Step 5: Create log directory
echo ""
echo -e "${CYAN}[Step 5/7]${NC} Creating log directory..."
mkdir -p /var/log/openresty
chown www-data:www-data /var/log/openresty

# Step 6: Test OpenResty config
echo ""
echo -e "${CYAN}[Step 6/7]${NC} Testing OpenResty configuration..."
/usr/local/openresty/bin/openresty -t

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} Config test failed!"
    echo "Please check /usr/local/openresty/nginx/conf/nginx.conf"
    exit 1
fi

# Step 7: Create systemd service for OpenResty
echo ""
echo -e "${CYAN}[Step 7/7]${NC} Creating systemd service..."
cat > /etc/systemd/system/openresty.service << 'EOF'
[Unit]
Description=OpenResty - High Performance Web Server
Documentation=https://openresty.org/
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/openresty.pid
ExecStartPre=/usr/local/openresty/bin/openresty -t
ExecStart=/usr/local/openresty/bin/openresty
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable openresty
systemctl start openresty

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}       Migration Successful!                   ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}✓${NC} OpenResty is now running"
    echo -e "${GREEN}✓${NC} Lua Auto SSL is enabled"
    echo -e "${GREEN}✓${NC} All services should be working"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. Verify all services: systemctl status openresty xray"
    echo "  2. Test XRAY protocols (VMESS, VLESS, TROJAN)"
    echo "  3. Test SSH services"
    echo "  4. Monitor logs: tail -f /var/log/openresty/error.log"
    echo ""
    echo -e "${CYAN}Note:${NC} Nginx backup location: /root/nginx-backup/"
else
    echo -e "${RED}[ERROR]${NC} Failed to start OpenResty!"
    echo "Check logs: journalctl -xe"
    exit 1
fi
