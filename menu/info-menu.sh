#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

DOMAIN=$(cat /root/domain.txt)
IP=$(curl -s ifconfig.me)

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              INFORMATION & STATUS                   ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Server Info
echo -e "${YELLOW}━━━ SERVER INFORMATION ━━━${NC}"
echo -e "${GREEN}Domain${NC}       : $DOMAIN"
echo -e "${GREEN}IP Address${NC}   : $IP"
echo -e "${GREEN}Hostname${NC}     : $(hostname)"
echo -e "${GREEN}Kernel${NC}       : $(uname -r)"
echo -e "${GREEN}Uptime${NC}       : $(uptime -p | cut -d " " -f 2-10)"
echo ""

# System Resources
TOTAL_RAM=$(free -m | awk 'NR==2{print $2}')
USED_RAM=$(free -m | awk 'NR==2{print $3}')
RAM_PERCENT=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')

TOTAL_DISK=$(df -h / | awk 'NR==2{print $2}')
USED_DISK=$(df -h / | awk 'NR==2{print $3}')
DISK_PERCENT=$(df -h / | awk 'NR==2{print $5}')

CPU_CORES=$(nproc)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "%.1f", 100 - $1}')

echo -e "${YELLOW}━━━ SYSTEM RESOURCES ━━━${NC}"
echo -e "${GREEN}RAM${NC}          : $USED_RAM MB / $TOTAL_RAM MB (${RAM_PERCENT}%)"
echo -e "${GREEN}Disk${NC}         : $USED_DISK / $TOTAL_DISK ($DISK_PERCENT)"
echo -e "${GREEN}CPU Cores${NC}    : $CPU_CORES"
echo -e "${GREEN}CPU Usage${NC}    : ${CPU_USAGE}%"
echo ""

# Service Status
echo -e "${YELLOW}━━━ SERVICE STATUS ━━━${NC}"
services=("ssh" "dropbear" "stunnel4" "squid" "nginx" "xray" "telegram-bot")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        echo -e "${GREEN}[✓]${NC} $service"
    else
        echo -e "${RED}[✗]${NC} $service"
    fi
done
echo ""

# Account Statistics
SSH_TOTAL=$(find /etc/tunneling/ssh -name "*.json" 2>/dev/null | wc -l)
VMESS_TOTAL=$(find /etc/tunneling/vmess -name "*.json" 2>/dev/null | wc -l)
VLESS_TOTAL=$(find /etc/tunneling/vless -name "*.json" 2>/dev/null | wc -l)
TROJAN_TOTAL=$(find /etc/tunneling/trojan -name "*.json" 2>/dev/null | wc -l)
TOTAL_ACCOUNTS=$((SSH_TOTAL + VMESS_TOTAL + VLESS_TOTAL + TROJAN_TOTAL))

echo -e "${YELLOW}━━━ ACCOUNT STATISTICS ━━━${NC}"
echo -e "${GREEN}SSH${NC}          : $SSH_TOTAL accounts"
echo -e "${GREEN}VMESS${NC}        : $VMESS_TOTAL accounts"
echo -e "${GREEN}VLESS${NC}        : $VLESS_TOTAL accounts"
echo -e "${GREEN}TROJAN${NC}       : $TROJAN_TOTAL accounts"
echo -e "${GREEN}Total${NC}        : $TOTAL_ACCOUNTS accounts"
echo ""

# Port Information
echo -e "${YELLOW}━━━ PORT INFORMATION ━━━${NC}"
echo -e "${GREEN}SSH:${NC}"
echo -e "  OpenSSH    : 22"
echo -e "  Dropbear   : 109, 143"
echo -e "  SSL/TLS    : 442 (Stunnel Dropbear), 777 (Stunnel OpenSSH)"
echo -e "  Squid      : 3128, 8080"
echo -e "  WebSocket  : 80, 8080 (WS), 443, 8443 (WSS)"
echo -e "  BadVPN     : 7300 (TCP/UDP)"
echo ""
echo -e "${GREEN}XRAY Core:${NC}"
echo -e "  VMESS WS   : 443 (TLS), 80 (Non-TLS), 2082, 2086, 2095, 8080, 8443"
echo -e "  VLESS WS   : 443 (TLS), 80 (Non-TLS), 2082, 2087, 2096, 8443"
echo -e "  TROJAN WS  : 443 (TLS), 2087"
echo -e "  gRPC       : 443 (All protocols support gRPC)"
echo ""
echo -e "${GREEN}Web Services:${NC}"
echo -e "  NGINX      : 80 (HTTP), 443 (HTTPS), 89 (HTTP No-SSL)"
echo -e "  Status     : https://$DOMAIN (Landing Page + Metrics)"
echo -e "  Config DL  : 89 (OVPN Config Download)"
echo ""
echo -e "${GREEN}Additional:${NC}"
echo -e "  DNS        : 53 (UDP)"
echo -e "  OpenVPN    : 1194 (UDP)"
echo ""

# Installation Info
if [ -f /etc/tunneling/config.json ]; then
    INSTALL_DATE=$(jq -r '.install_date' /etc/tunneling/config.json)
    VERSION=$(jq -r '.version' /etc/tunneling/config.json)
    
    echo -e "${YELLOW}━━━ INSTALLATION INFO ━━━${NC}"
    echo -e "${GREEN}Version${NC}      : $VERSION"
    echo -e "${GREEN}Install Date${NC} : $INSTALL_DATE"
    echo ""
fi

# Last Backup Info
LAST_BACKUP=$(ls -t /etc/tunneling/backup/*.tar.gz 2>/dev/null | head -1)
if [ ! -z "$LAST_BACKUP" ]; then
    BACKUP_NAME=$(basename "$LAST_BACKUP")
    BACKUP_SIZE=$(du -h "$LAST_BACKUP" | awk '{print $1}')
    BACKUP_DATE=$(stat -c %y "$LAST_BACKUP" | cut -d' ' -f1)
    
    echo -e "${YELLOW}━━━ LAST BACKUP ━━━${NC}"
    echo -e "${GREEN}File${NC}         : $BACKUP_NAME"
    echo -e "${GREEN}Size${NC}         : $BACKUP_SIZE"
    echo -e "${GREEN}Date${NC}         : $BACKUP_DATE"
    echo ""
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back to menu"
/usr/local/sbin/tunneling/menu/main-menu.sh
