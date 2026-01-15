#!/bin/bash

# Update Script for AUTOSCRIPT TUNNELING

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}         AUTOSCRIPT TUNNELING UPDATE                 ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get current version
CURRENT_VERSION=$(jq -r '.version' /etc/tunneling/config.json 2>/dev/null || echo "Unknown")
echo -e "${YELLOW}Current Version:${NC} $CURRENT_VERSION"
echo ""

# Backup before update
echo -e "${CYAN}[INFO]${NC} Creating backup before update..."

# Create backup directory if not exists
mkdir -p /etc/tunneling/backup

BACKUP_FILE="/etc/tunneling/backup/pre-update-$(date +%Y%m%d-%H%M%S).tar.gz"

# Backup with error handling
if [ -d "/usr/local/sbin/tunneling" ]; then
    tar -czf "$BACKUP_FILE" \
        -C /usr/local/sbin tunneling \
        2>/dev/null
    
    if [ $? -eq 0 ] && [ -f "$BACKUP_FILE" ]; then
        echo -e "${GREEN}[✓]${NC} Backup created: $(basename $BACKUP_FILE)"
    else
        echo -e "${YELLOW}[!]${NC} Backup skipped (optional)"
    fi
else
    echo -e "${YELLOW}[!]${NC} No existing installation found, skipping backup"
fi

echo ""
echo -e "${CYAN}[INFO]${NC} Downloading latest version..."

# Download update
cd /tmp
BASE_URL="https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling-v2/main"

# Download menu scripts
echo -e "${CYAN}[1/5]${NC} Downloading menu scripts..."
wget -q -O main-menu.sh "${BASE_URL}/menu/main-menu.sh"
wget -q -O ssh-menu.sh "${BASE_URL}/menu/ssh-menu.sh"
wget -q -O vmess-menu.sh "${BASE_URL}/menu/vmess-menu.sh"
wget -q -O vless-menu.sh "${BASE_URL}/menu/vless-menu.sh"
wget -q -O trojan-menu.sh "${BASE_URL}/menu/trojan-menu.sh"
wget -q -O system-menu.sh "${BASE_URL}/menu/system-menu.sh"
wget -q -O backup-menu.sh "${BASE_URL}/menu/backup-menu.sh"
wget -q -O bot-menu.sh "${BASE_URL}/menu/bot-menu.sh"
wget -q -O settings-menu.sh "${BASE_URL}/menu/settings-menu.sh"
wget -q -O info-menu.sh "${BASE_URL}/menu/info-menu.sh"

# Download SSH scripts
echo -e "${CYAN}[2/5]${NC} Downloading SSH scripts..."
for script in create trial renew delete check list delete-expired lock unlock details limit-ip limit-quota; do
    wget -q -O ssh-${script}.sh "${BASE_URL}/ssh/ssh-${script}.sh"
done
wget -q -O setup-dropbear.sh "${BASE_URL}/ssh/setup-dropbear.sh"
wget -q -O setup-stunnel.sh "${BASE_URL}/ssh/setup-stunnel.sh"
wget -q -O setup-squid.sh "${BASE_URL}/ssh/setup-squid.sh"
wget -q -O setup-tuntap.sh "${BASE_URL}/ssh/setup-tuntap.sh"

# Download system scripts

# Download system scripts
echo -e "${CYAN}[3/5]${NC} Downloading system scripts..."
# System monitoring and management
wget -q -O check-services.sh "${BASE_URL}/system/check-services.sh"
wget -q -O monitor-vps.sh "${BASE_URL}/system/monitor-vps.sh"
wget -q -O backup-now.sh "${BASE_URL}/system/backup-now.sh"
wget -q -O restore-backup.sh "${BASE_URL}/system/restore-backup.sh"
wget -q -O auto-backup.sh "${BASE_URL}/system/auto-backup.sh"
wget -q -O delete-expired.sh "${BASE_URL}/system/delete-expired.sh"
wget -q -O setup-nginx.sh "${BASE_URL}/system/setup-nginx.sh"
wget -q -O restart-all.sh "${BASE_URL}/system/restart-all.sh"
wget -q -O restart-service.sh "${BASE_URL}/system/restart-service.sh"
wget -q -O speedtest.sh "${BASE_URL}/system/speedtest.sh"
wget -q -O delete-all-expired.sh "${BASE_URL}/system/delete-all-expired.sh"
wget -q -O limit-speed.sh "${BASE_URL}/system/limit-speed.sh"
wget -q -O monitor-service.sh "${BASE_URL}/system/monitor-service.sh"
wget -q -O check-logs.sh "${BASE_URL}/system/check-logs.sh"
wget -q -O auto-reboot-settings.sh "${BASE_URL}/system/auto-reboot-settings.sh"

# Settings menu scripts
wget -q -O change-domain.sh "${BASE_URL}/system/change-domain.sh"
wget -q -O change-banner.sh "${BASE_URL}/system/change-banner.sh"
wget -q -O change-port.sh "${BASE_URL}/system/change-port.sh"
wget -q -O change-timezone.sh "${BASE_URL}/system/change-timezone.sh"
wget -q -O fix-error-domain.sh "${BASE_URL}/system/fix-error-domain.sh"
wget -q -O fix-error-proxy.sh "${BASE_URL}/system/fix-error-proxy.sh"
wget -q -O renew-ssl.sh "${BASE_URL}/system/renew-ssl.sh"
wget -q -O auto-record-wildcard.sh "${BASE_URL}/system/auto-record-wildcard.sh"
wget -q -O limit-speed-settings.sh "${BASE_URL}/system/limit-speed-settings.sh"
wget -q -O reset-settings.sh "${BASE_URL}/system/reset-settings.sh"

# Download XRAY scripts
echo -e "${CYAN}[4/5]${NC} Downloading XRAY scripts..."
wget -q -O setup-xray.sh "${BASE_URL}/xray/setup-xray.sh"

# VMESS scripts
for script in create trial list renew delete check delete-expired lock unlock details limit-ip limit-quota; do
    wget -q -O vmess-${script}.sh "${BASE_URL}/xray/vmess-${script}.sh"
done

# VLESS scripts
for script in create trial list renew delete check delete-expired lock unlock details limit-ip limit-quota; do
    wget -q -O vless-${script}.sh "${BASE_URL}/xray/vless-${script}.sh"
done

# TROJAN scripts
for script in create trial list renew delete check delete-expired lock unlock details limit-ip limit-quota; do
    wget -q -O trojan-${script}.sh "${BASE_URL}/xray/trojan-${script}.sh"
done

wget -q -O placeholder.sh "${BASE_URL}/xray/placeholder.sh"

# Download bot scripts
echo -e "${CYAN}[5/5]${NC} Downloading bot scripts..."
wget -q -O telegram_bot.py "${BASE_URL}/bot/telegram_bot.py"
wget -q -O bot-setup.sh "${BASE_URL}/bot/bot-setup.sh"
wget -q -O bot-start.sh "${BASE_URL}/bot/bot-start.sh"
wget -q -O bot-stop.sh "${BASE_URL}/bot/bot-stop.sh"
wget -q -O bot-restart.sh "${BASE_URL}/bot/bot-restart.sh"
wget -q -O bot-status.sh "${BASE_URL}/bot/bot-status.sh"
wget -q -O bot-auto-order.sh "${BASE_URL}/bot/bot-auto-order.sh"
wget -q -O bot-payment.sh "${BASE_URL}/bot/bot-payment.sh"
wget -q -O bot-price.sh "${BASE_URL}/bot/bot-price.sh"
wget -q -O bot-notification.sh "${BASE_URL}/bot/bot-notification.sh"
wget -q -O bot-test.sh "${BASE_URL}/bot/bot-test.sh"

# Validate all critical files were downloaded
echo ""
echo -e "${CYAN}[INFO]${NC} Validating downloaded files..."
failed=0
for file in main-menu.sh ssh-create.sh setup-xray.sh; do
    if [ ! -s "$file" ]; then
        echo -e "${RED}[ERROR] Failed to download: $file${NC}"
        failed=1
    fi
done


if [ $failed -eq 0 ]; then
    echo -e "${GREEN}[✓]${NC} All files validated successfully"
    echo ""
    echo -e "${GREEN}[✓]${NC} Download completed"
    
    # Install updates
    echo ""
    echo -e "${CYAN}[INFO]${NC} Installing updates..."
    
    # Copy all scripts to installation directory
    cp -f *.sh /usr/local/sbin/tunneling/ 2>/dev/null
    cp -f telegram_bot.py /usr/local/sbin/tunneling/ 2>/dev/null
    
    # Set permissions
    chmod +x /usr/local/sbin/tunneling/*.sh
    chmod +x /usr/local/sbin/tunneling/telegram_bot.py
    
    echo -e "${GREEN}[✓]${NC} Files installed"
    
    # Update version
    NEW_VERSION="1.0.1"
    jq ".version = \"$NEW_VERSION\" | .updated = \"$(date +%Y-%m-%d)\"" \
        /etc/tunneling/config.json > /tmp/config.json.tmp && \
        mv /tmp/config.json.tmp /etc/tunneling/config.json
    
    # Clean up
    rm -f /tmp/*.sh
    rm -f /tmp/*.py
    
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}            UPDATE COMPLETED SUCCESSFULLY!           ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Previous Version:${NC} $CURRENT_VERSION"
    echo -e "${YELLOW}Current Version:${NC}  $NEW_VERSION"
    echo -e "${YELLOW}Updated:${NC}          $(date)"
    echo -e "${YELLOW}Backup File:${NC}      $(basename $BACKUP_FILE)"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}✓ Menu scripts updated${NC}"
    echo -e "${GREEN}✓ SSH scripts updated${NC}"
    echo -e "${GREEN}✓ System scripts updated${NC}"
    echo -e "${GREEN}✓ XRAY scripts updated${NC}"
    echo -e "${GREEN}✓ Bot scripts updated${NC}"
    echo -e "${GREEN}✓ Settings menu scripts added${NC}"
    echo ""
    echo -e "${YELLOW}Restart telegram bot if running:${NC}"
    echo -e "  systemctl restart telegram-bot"
    echo ""
else
    echo -e "${RED}[✗]${NC} Download validation failed!"
    echo -e "${YELLOW}[INFO]${NC} Restoring from backup..."
    if [ -f "$BACKUP_FILE" ]; then
        tar -xzf "$BACKUP_FILE" -C /usr/local/sbin/ 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[✓]${NC} Backup restored successfully"
        else
            echo -e "${RED}[ERROR]${NC} Failed to restore backup"
        fi
    else
        echo -e "${YELLOW}[WARNING]${NC} No backup file found to restore"
    fi
    echo -e "${RED}Please check your internet connection and try again${NC}"
    exit 1
fi

read -n 1 -s -r -p "Press any key to continue"
