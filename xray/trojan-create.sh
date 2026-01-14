#!/bin/bash
# TROJAN Account Creation

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}        CREATE TROJAN ACCOUNT             ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username: " username
read -p "Duration (days): " days

# Generate UUID
uuid=$(cat /proc/sys/kernel/random/uuid)

# Calculate expiry
exp_date=$(date -d "+${days} days" +"%Y-%m-%d")
exp_timestamp=$(date -d "$exp_date" +%s)

# Get domain
domain=$(cat /root/domain.txt)

# Create JSON record
cat > /etc/tunneling/trojan/${username}.json << EOF
{
    "username": "$username",
    "uuid": "$uuid",
    "created": $(date +%s),
    "expired": $exp_timestamp,
    "limit_ip": 0,
    "limit_quota": 0
}
EOF

# Add to XRAY config
CONFIG_FILE="/usr/local/etc/xray/config.json"

# Check if user already exists in config
if grep -q "\"password\": \"$uuid\"" $CONFIG_FILE; then
    echo -e "${RED}User already exists in XRAY config!${NC}"
    exit 1
fi

# Add client to TROJAN inbound
jq --arg password "$uuid" --arg email "$username@$domain" \
   '.inbounds |= map(if .protocol == "trojan" then .settings.clients += [{"password": $password, "email": $email}] else . end)' \
   $CONFIG_FILE > /tmp/xray-config.tmp && mv /tmp/xray-config.tmp $CONFIG_FILE

# Validate JSON config
echo -e "${CYAN}Validating XRAY config...${NC}"
if ! jq empty $CONFIG_FILE 2>/dev/null; then
    echo -e "${RED}Invalid JSON config! Restoring backup...${NC}"
    if [ -f "${CONFIG_FILE}.bak" ]; then
        mv ${CONFIG_FILE}.bak $CONFIG_FILE
    fi
    rm -f /etc/tunneling/trojan/${username}.json
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
    if [ -f "${CONFIG_FILE}.bak" ]; then
        mv ${CONFIG_FILE}.bak $CONFIG_FILE
        systemctl restart xray
    fi
    rm -f /etc/tunneling/trojan/${username}.json
    exit 1
fi

echo -e "${GREEN}XRAY service running successfully!${NC}"

# Generate trojan:// links
# Port 443 with TLS
trojan_link_tls="trojan://$uuid@$domain:443?security=tls&type=ws&host=$domain&path=/trojan&sni=$domain#$username-$domain"

# Port 80 without TLS
trojan_link_80="trojan://$uuid@$domain:80?security=none&type=ws&host=$domain&path=/trojan#$username-$domain-80"

echo ""
echo -e "${GREEN}✓ TROJAN Account created successfully!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Username:${NC} $username"
echo -e "${YELLOW}UUID/Password:${NC} $uuid"
echo -e "${YELLOW}Domain:${NC} $domain"
echo -e "${YELLOW}Expired:${NC} $exp_date"
echo -e "${YELLOW}Network:${NC} WebSocket (ws)"
echo -e "${YELLOW}Path:${NC} /trojan"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}TROJAN Link Port 443 (TLS):${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}$trojan_link_tls${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}TROJAN Link Port 80 (Non-TLS):${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}$trojan_link_80${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Note: Import link above to V2RayNG/V2RayN/Clash${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."

