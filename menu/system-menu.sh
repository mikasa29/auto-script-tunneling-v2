#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              SYSTEM MANAGEMENT MENU                 ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Service Control:${NC}"
echo -e "${GREEN}  [1]${NC} Check Running Services"
echo -e "${GREEN}  [2]${NC} Monitor VPS (CPU, RAM, Bandwidth)"
echo -e "${GREEN}  [3]${NC} Restart All Services"
echo -e "${GREEN}  [4]${NC} Restart Specific Service"
echo -e "${GREEN}  [5]${NC} Monitor Service Status"
echo ""
echo -e "${YELLOW}Logs & Network:${NC}"
echo -e "${GREEN}  [6]${NC} Speedtest"
echo -e "${GREEN}  [7]${NC} View Logs (Detailed)"
echo -e "${GREEN}  [8]${NC} Check Logs"
echo ""
echo -e "${YELLOW}Settings & Maintenance:${NC}"
echo -e "${GREEN}  [9]${NC} Auto Reboot Settings"
echo -e "${GREEN} [10]${NC} Change Auto Reboot Settings"
echo -e "${GREEN} [11]${NC} Limit Speed VPS (Active Limit)"
echo -e "${GREEN} [12]${NC} Limit Speed Settings"
echo -e "${GREEN} [13]${NC} Delete All Expired Accounts"
echo -e "${GREEN} [14]${NC} Update/Repair Scripts"
echo ""
echo -e "${YELLOW}SSL & Fixes:${NC}"
echo -e "${GREEN} [15]${NC} Renew SSL Certificate"
echo -e "${GREEN} [16]${NC} Configure Cloudflare / Wildcard SSL"
echo -e "${GREEN} [17]${NC} Check Cloudflare DNS Records"
echo -e "${GREEN} [18]${NC} Fix/Create Cloudflare DNS Records"
echo -e "${GREEN} [19]${NC} View Auto SSL Analytics"
echo -e "${GREEN} [20]${NC} Fix Metrics PHP (Landing Page)"
echo -e "${GREEN} [21]${NC} Fix Corrupted XRAY Config"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  [0]${NC} Back to Main Menu"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select Menu [0-21]: " menu

case $menu in
    1)
        /usr/local/sbin/tunneling/system/check-services.sh
        ;;
    2)
        /usr/local/sbin/tunneling/system/monitor-vps.sh
        ;;
    3)
        /usr/local/sbin/tunneling/system/restart-all.sh
        ;;
    4)
        /usr/local/sbin/tunneling/system/restart-service.sh
        ;;
    5)
        /usr/local/sbin/tunneling/system/monitor-service.sh
        ;;
    6)
        /usr/local/sbin/tunneling/system/speedtest.sh
        ;;
    7)
        /usr/local/sbin/tunneling/system/view-logs.sh
        ;;
    8)
        /usr/local/sbin/tunneling/system/check-logs.sh
        ;;
    9)
        /usr/local/sbin/tunneling/system/auto-reboot-settings.sh
        ;;
    10)
        /usr/local/sbin/tunneling/system/change-auto-reboot-settings.sh
        ;;
    11)
        /usr/local/sbin/tunneling/system/limit-speed.sh
        ;;
    12)
        /usr/local/sbin/tunneling/system/limit-speed-settings.sh
        ;;
    13)
        /usr/local/sbin/tunneling/system/delete-all-expired.sh
        ;;
    14)
        /usr/local/sbin/tunneling/fix-install.sh
        ;;
    15)
        /usr/local/sbin/tunneling/system/renew-ssl.sh
        ;;
    16)
        /usr/local/sbin/tunneling/system/setup-cloudflare-interactive.sh
        ;;
    17)
        /usr/local/sbin/tunneling/system/check-cloudflare-dns.sh
        ;;
    18)
        /usr/local/sbin/tunneling/system/fix-cloudflare-dns.sh
        ;;
    19)
        /usr/local/sbin/tunneling/system/view-auto-ssl-analytics.sh
        ;;
    20)
        /usr/local/sbin/tunneling/system/fix-metrics-php.sh
        ;;
    21)
        /usr/local/sbin/tunneling/system/fix-xray-config.sh
        ;;
    0)
        /usr/local/sbin/tunneling/menu/main-menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/menu/system-menu.sh
        ;;
esac
