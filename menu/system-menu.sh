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
echo -e "${GREEN}  [1]${NC} Check Running Services"
echo -e "${GREEN}  [2]${NC} Restart All Services"
echo -e "${GREEN}  [3]${NC} Restart Specific Service"
echo -e "${GREEN}  [4]${NC} Monitor VPS (CPU, RAM, Bandwidth)"
echo -e "${GREEN}  [5]${NC} Speedtest"
echo -e "${GREEN}  [6]${NC} Delete All Expired Accounts"
echo -e "${GREEN}  [7]${NC} Limit Speed VPS"
echo -e "${GREEN}  [8]${NC} Monitor Service Status"
echo -e "${GREEN}  [9]${NC} View Logs (Detailed)"
echo -e "${GREEN} [10]${NC} Check Logs"
echo -e "${GREEN} [11]${NC} Auto Reboot Settings"
echo -e "${GREEN} [12]${NC} Update/Repair Scripts"
echo -e "${GREEN} [13]${NC} Renew SSL Certificate"
echo -e "${GREEN} [14]${NC} Change Auto Reboot Settings"
echo -e "${GREEN} [15]${NC} Limit Speed Settings"
echo -e "${GREEN} [16]${NC} View Auto SSL Analytics"
echo -e "${GREEN} [17]${NC} Fix Metrics PHP (Landing Page)"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  [0]${NC} Back to Main Menu"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select Menu [0-17]: " menu

case $menu in
    1)
        /usr/local/sbin/tunneling/system/check-services.sh
        ;;
    2)
        /usr/local/sbin/tunneling/system/restart-all.sh
        ;;
    3)
        /usr/local/sbin/tunneling/system/restart-service.sh
        ;;
    4)
        /usr/local/sbin/tunneling/system/monitor-vps.sh
        ;;
    5)
        /usr/local/sbin/tunneling/system/speedtest.sh
        ;;
    6)
        /usr/local/sbin/tunneling/system/delete-all-expired.sh
        ;;
    7)
        /usr/local/sbin/tunneling/system/limit-speed.sh
        ;;
    8)
        /usr/local/sbin/tunneling/system/monitor-service.sh
        ;;
    9)
        /usr/local/sbin/tunneling/system/view-logs.sh
        ;;
    10)
        /usr/local/sbin/tunneling/system/check-logs.sh
        ;;
    11)
        /usr/local/sbin/tunneling/system/auto-reboot-settings.sh
        ;;
    12)
        /usr/local/sbin/tunneling/fix-install.sh
        ;;
    13)
        /usr/local/sbin/tunneling/system/renew-ssl.sh
        ;;
    14)
        /usr/local/sbin/tunneling/system/change-auto-reboot-settings.sh
        ;;
    15)
        /usr/local/sbin/tunneling/system/limit-speed-settings.sh
        ;;
    16)
        /usr/local/sbin/tunneling/system/view-auto-ssl-analytics.sh
        ;;
    17)
        /usr/local/sbin/tunneling/system/fix-metrics-php.sh
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
