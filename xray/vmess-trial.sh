#!/bin/bash
# VMESS Trial Account (1 Hour)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}      CREATE TRIAL VMESS ACCOUNT        ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Generate random username
username="trial$(date +%s)"

# Generate UUID
uuid=$(cat /proc/sys/kernel/random/uuid)

# Calculate expiry (1 hour)
exp_date=$(date -d "+1 hours" +"%Y-%m-%d %H:%M")
exp_timestamp=$(date -d "+1 hours" +%s)

# Get domain
domain=$(cat /root/domain.txt)

# Create JSON record
cat > /etc/tunneling/vmess/${username}.json << EOF
{
    "username": "$username",
    "uuid": "$uuid",
    "created": $(date +%s),
    "expired": $exp_timestamp,
    "limit_ip": 1,
    "limit_quota": 1
}
EOF

# Add to XRAY config
CONFIG_FILE="/usr/local/etc/xray/config.json"
jq --arg uuid "$uuid" --arg email "TRIAL-$username@$domain" \
   '.inbounds |= map(if .protocol == "vmess" then .settings.clients += [{"id": $uuid, "alterId": 0, "email": $email}] else . end)' \
   $CONFIG_FILE > /tmp/xray-config.tmp && mv /tmp/xray-config.tmp $CONFIG_FILE

# Validate JSON config
echo -e "${CYAN}Validating XRAY config...${NC}"
if ! jq empty $CONFIG_FILE 2>/dev/null; then
    echo -e "${RED}Invalid JSON config! Restoring backup...${NC}"
    if [ -f "${CONFIG_FILE}.bak" ]; then
        mv ${CONFIG_FILE}.bak $CONFIG_FILE
    fi
    rm -f /etc/tunneling/vmess/${username}.json
    exit 1
fi

# Backup current config
cp $CONFIG_FILE ${CONFIG_FILE}.bak

# Restart XRAY
echo -e "${CYAN}Restarting XRAY service...${NC}"
systemctl restart xray

# Wait for service to be ready
echo -e "${CYAN}Waiting for XRAY to start...${NC}"
sleep 2

# Check if XRAY is running
if ! systemctl is-active --quiet xray; then
    echo -e "${RED}Failed to start XRAY! Check logs with: journalctl -u xray -n 50${NC}"
    # Restore backup
    if [ -f "${CONFIG_FILE}.bak" ]; then
        mv ${CONFIG_FILE}.bak $CONFIG_FILE
        systemctl restart xray
    fi
    rm -f /etc/tunneling/vmess/${username}.json
    exit 1
fi

echo -e "${GREEN}XRAY service running successfully!${NC}"

# Generate vmess:// link
vmess_json=$(cat <<EOF
{
  "v": "2",
  "ps": "TRIAL-$username-$domain",
  "add": "$domain",
  "port": "443",
  "id": "$uuid",
  "aid": "0",
  "net": "ws",
  "type": "none",
  "host": "$domain",
  "path": "/vmess",
  "tls": "tls",
  "sni": "$domain"
}
EOF
)

vmess_link_tls="vmess://$(echo -n $vmess_json | base64 -w 0)"

# Generate vmess:// link for port 80 (non-TLS)
vmess_json_80=$(cat <<EOF
{
  "v": "2",
  "ps": "TRIAL-$username-$domain-80",
  "add": "$domain",
  "port": "80",
  "id": "$uuid",
  "aid": "0",
  "net": "ws",
  "type": "none",
  "host": "$domain",
  "path": "/vmess",
  "tls": "",
  "sni": ""
}
EOF
)

vmess_link_80="vmess://$(echo -n $vmess_json_80 | base64 -w 0)"

echo ""
echo -e "${GREEN}✓ VMESS Trial created successfully!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Username:${NC} $username"
echo -e "${YELLOW}UUID:${NC} $uuid"
echo -e "${YELLOW}Domain:${NC} $domain"
echo -e "${YELLOW}Expired:${NC} $exp_date (1 Hour)"
echo -e "${YELLOW}Port TLS:${NC} 443"
echo -e "${YELLOW}Port HTTP:${NC} 80"
echo -e "${YELLOW}Path:${NC} /vmess"
echo -e "${YELLOW}Limit:${NC} 1 IP, 1 GB"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}VMESS Link TLS (Port 443):${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}$vmess_link_tls${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}VMESS Link HTTP (Port 80):${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}$vmess_link_80${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Note: Import link above to V2RayNG/V2RayN/Clash${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
