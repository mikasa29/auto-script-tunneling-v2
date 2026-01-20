#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}            RESTART ALL SERVICES                   ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Restarting all VPN services...${NC}"
echo ""

# Restart SSH services
echo -e "${CYAN}[1/7] Restarting SSH services...${NC}"
systemctl restart ssh
systemctl restart dropbear
systemctl restart stunnel4
systemctl restart squid
echo -e "${GREEN}✓ SSH services restarted${NC}"
echo ""

# Restart XRAY
echo -e "${CYAN}[2/7] Restarting XRAY...${NC}"
systemctl restart xray
echo -e "${GREEN}✓ XRAY restarted${NC}"
echo ""

# Restart NGINX
echo -e "${CYAN}[3/8] Restarting NGINX...${NC}"
if nginx -t > /dev/null 2>&1; then
    systemctl restart nginx
    echo -e "${GREEN}✓ NGINX restarted${NC}"
else
    echo -e "${RED}✘ NGINX Config Error! Restart aborted.${NC}"
    echo -e "${YELLOW}  Run 'nginx -t' to see details.${NC}"
fi
echo ""

# Restart PHP-FPM (Auto-detect version)
echo -e "${CYAN}[4/8] Restarting PHP-FPM...${NC}"
if pgrep -f "php-fpm" > /dev/null; then
    # Find the service name accurately
    PHP_SERVICE=$(systemctl list-units --type=service | grep "php.*fpm" | awk '{print $1}' | head -n 1)
    if [ -n "$PHP_SERVICE" ]; then
        systemctl restart "$PHP_SERVICE"
        echo -e "${GREEN}✓ $PHP_SERVICE restarted${NC}"
    else
        echo -e "${YELLOW}⚠ PHP-FPM running but service not found${NC}"
    fi
else
    echo -e "${YELLOW}⚠ PHP-FPM not running${NC}"
fi
echo ""

# Restart Cron
echo -e "${CYAN}[5/8] Restarting Cron...${NC}"
systemctl restart cron
echo -e "${GREEN}✓ Cron restarted${NC}"
echo ""

# Restart Netfilter
echo -e "${CYAN}[6/8] Restarting Netfilter...${NC}"
if systemctl list-unit-files | grep -q "netfilter-persistent"; then
    systemctl restart netfilter-persistent
    echo -e "${GREEN}✓ Netfilter restarted${NC}"
else
    echo -e "${YELLOW}⚠ Netfilter service not found (Skipped)${NC}"
fi
echo ""

# Restart fail2ban if installed
echo -e "${CYAN}[7/8] Restarting fail2ban...${NC}"
if systemctl is-active --quiet fail2ban; then
    systemctl restart fail2ban
    echo -e "${GREEN}✓ fail2ban restarted${NC}"
else
    echo -e "${YELLOW}✓ fail2ban not installed${NC}"
fi
echo ""

# Clear cache
echo -e "${CYAN}[8/8] Clearing cache...${NC}"
sync; echo 3 > /proc/sys/vm/drop_caches
echo -e "${GREEN}✓ Cache cleared${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}All services restarted successfully!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/menu/system-menu.sh
