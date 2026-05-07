#!/bin/bash
# =========================================
# Fix Missing Scripts - Download All Files
# Run this if you get "No such file" errors
# =========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}       Fix Installation - Download Missing Files     ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

BASE_URL="https://github.com/mikasa29/auto-script-tunneling-v2/main"
INSTALL_DIR="/usr/local/sbin/tunneling"
BACKUP_DIR="/usr/local/sbin/tunneling/backup_$(date +%Y%m%d_%H%M%S)"

cd $INSTALL_DIR || exit 1

# Ask for backup
echo -e "${YELLOW}Existing files will be replaced.${NC}"
read -p "Create backup before replacing? (y/n): " do_backup
echo ""

if [[ "$do_backup" == "y" ]]; then
    echo -e "${CYAN}Creating backup...${NC}"
    mkdir -p $BACKUP_DIR
    
    # Backup existing files
    for file in *.sh *.py; do
        if [ -f "$file" ]; then
            cp "$file" "$BACKUP_DIR/" 2>/dev/null
        fi
    done
    
    echo -e "${GREEN}✓ Backup created at: $BACKUP_DIR${NC}"
    echo ""
fi

echo -e "${CYAN}[1/5]${NC} Downloading menu scripts..."
rm -f main-menu.sh ssh-menu.sh vmess-menu.sh vless-menu.sh trojan-menu.sh system-menu.sh backup-menu.sh bot-menu.sh settings-menu.sh info-menu.sh
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

echo -e "${CYAN}[2/4]${NC} Downloading SSH scripts..."
rm -f ssh-create.sh ssh-trial.sh ssh-renew.sh ssh-delete.sh ssh-check.sh ssh-list.sh ssh-delete-expired.sh ssh-lock.sh ssh-unlock.sh ssh-details.sh ssh-limit-ip.sh ssh-limit-quota.sh setup-dropbear.sh setup-stunnel.sh setup-squid.sh setup-tuntap.sh
wget -q -O ssh-create.sh "${BASE_URL}/ssh/ssh-create.sh"
wget -q -O ssh-trial.sh "${BASE_URL}/ssh/ssh-trial.sh"
wget -q -O ssh-renew.sh "${BASE_URL}/ssh/ssh-renew.sh"
wget -q -O ssh-delete.sh "${BASE_URL}/ssh/ssh-delete.sh"
wget -q -O ssh-check.sh "${BASE_URL}/ssh/ssh-check.sh"
wget -q -O ssh-list.sh "${BASE_URL}/ssh/ssh-list.sh"
wget -q -O ssh-delete-expired.sh "${BASE_URL}/ssh/ssh-delete-expired.sh"
wget -q -O ssh-lock.sh "${BASE_URL}/ssh/ssh-lock.sh"
wget -q -O ssh-unlock.sh "${BASE_URL}/ssh/ssh-unlock.sh"
wget -q -O ssh-details.sh "${BASE_URL}/ssh/ssh-details.sh"
wget -q -O ssh-limit-ip.sh "${BASE_URL}/ssh/ssh-limit-ip.sh"
wget -q -O ssh-limit-quota.sh "${BASE_URL}/ssh/ssh-limit-quota.sh"
wget -q -O setup-dropbear.sh "${BASE_URL}/ssh/setup-dropbear.sh"
wget -q -O setup-stunnel.sh "${BASE_URL}/ssh/setup-stunnel.sh"
wget -q -O setup-squid.sh "${BASE_URL}/ssh/setup-squid.sh"
wget -q -O setup-tuntap.sh "${BASE_URL}/ssh/setup-tuntap.sh"

echo -e "${CYAN}[3/4]${NC} Downloading system scripts..."
# System monitoring and management
rm -f check-services.sh monitor-vps.sh backup-now.sh restore-backup.sh auto-backup.sh delete-expired.sh setup-nginx.sh restart-all.sh restart-service.sh speedtest.sh delete-all-expired.sh limit-speed.sh monitor-service.sh check-logs.sh auto-reboot-settings.sh
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
rm -f change-domain.sh change-banner.sh change-port.sh change-timezone.sh fix-error-domain.sh fix-error-proxy.sh renew-ssl.sh auto-record-wildcard.sh limit-speed-settings.sh reset-settings.sh
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

echo -e "${CYAN}[4/5]${NC} Downloading XRAY scripts..."
rm -f setup-xray.sh placeholder.sh
wget -q -O setup-xray.sh "${BASE_URL}/xray/setup-xray.sh"

# VMESS
for script in create trial list renew delete check delete-expired lock unlock details limit-ip limit-quota; do
    rm -f vmess-${script}.sh
    wget -q -O vmess-${script}.sh "${BASE_URL}/xray/vmess-${script}.sh"
done

# VLESS
for script in create trial list renew delete check delete-expired lock unlock details limit-ip limit-quota; do
    rm -f vless-${script}.sh
    wget -q -O vless-${script}.sh "${BASE_URL}/xray/vless-${script}.sh"
done

# TROJAN
for script in create trial list renew delete check delete-expired lock unlock details limit-ip limit-quota; do
    rm -f trojan-${script}.sh
    wget -q -O trojan-${script}.sh "${BASE_URL}/xray/trojan-${script}.sh"
done

wget -q -O placeholder.sh "${BASE_URL}/xray/placeholder.sh"

echo -e "${CYAN}[5/5]${NC} Downloading bot scripts..."
rm -f telegram_bot.py bot-setup.sh bot-start.sh bot-stop.sh bot-restart.sh bot-status.sh bot-auto-order.sh bot-payment.sh bot-price.sh bot-notification.sh bot-test.sh
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

echo ""
echo -e "${CYAN}[INFO]${NC} Setting permissions..."
chmod +x $INSTALL_DIR/*.sh

echo ""
echo -e "${GREEN}✓ All scripts downloaded successfully!${NC}"

if [[ "$do_backup" == "y" ]]; then
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Backup location: $BACKUP_DIR${NC}"
    echo -e "${YELLOW}To restore backup: cp $BACKUP_DIR/* $INSTALL_DIR/${NC}"
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}You can now run: menu${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
