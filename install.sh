#!/bin/bash
# =========================================
# AUTOSCRIPT TUNNELING VPN (ONLINE INSTALLER)
# Support: Ubuntu 22.04+ / Debian 11+
# Author: AUTOSCRIPT TUNNELING TEAM
# Description: Installs directly from GitHub without git clone
# =========================================

# Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Base URL & Install Dir
BASE_URL="https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling-v2/main"
INSTALL_DIR="/usr/local/sbin/tunneling"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}      AUTOSCRIPT TUNNELING VPN ONLINE INSTALLER     ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Set timezone
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# Get domain
read -p "Enter your domain: " domain
if [[ -z $domain ]]; then
    echo -e "${RED}Domain cannot be empty!${NC}"
    exit 1
fi
echo "$domain" > /root/domain.txt

# Get email for SSL certificate
read -p "Enter your email for SSL certificate: " email
if [[ -z $email ]]; then
    email="admin@${domain}"
    echo -e "${YELLOW}No email provided, using default: $email${NC}"
fi
echo "$email" > /root/email.txt

# Update and install dependencies
echo -e "${CYAN}[INFO]${NC} Updating system and installing dependencies..."
apt-get update
apt-get install -y \
    wget \
    curl \
    git \
    unzip \
    python3 \
    python3-pip \
    build-essential \
    cmake \
    screen \
    cron \
    socat \
    netfilter-persistent \
    jq \
    vnstat \
    nginx \
    certbot \
    python3-certbot-nginx \
    squid \
    dropbear \
    stunnel4 \
    fail2ban \
    htop \
    speedtest-cli \
    net-tools \
    dnsutils \
    bc

# Install BBR
echo -e "${CYAN}[INFO]${NC} Installing BBR..."
if ! grep -q "net.core.default_qdisc=fq" /etc/sysctl.conf; then
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
fi

# Create Directory Structure
mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/menu"
mkdir -p "$INSTALL_DIR/ssh"
mkdir -p "$INSTALL_DIR/system"
mkdir -p "$INSTALL_DIR/xray"
mkdir -p "$INSTALL_DIR/bot"

# Function to download file
download_file() {
    local source_path="$1"
    local dest_path="$2"
    
    echo -e "${YELLOW}Downloading $source_path...${NC}"
    wget -q -O "$dest_path" "${BASE_URL}/$source_path" 2>/dev/null || curl -sL "${BASE_URL}/$source_path" -o "$dest_path"
    
    if [[ ! -s "$dest_path" ]]; then
        echo -e "${RED}[ERROR] Failed to download $source_path${NC}"
    fi
}

echo -e "${CYAN}[INFO]${NC} Downloading scripts from GitHub..."

# --- MENU SCRIPTS ---
FILES_MENU=(
    "menu/main-menu.sh" "menu/ssh-menu.sh" "menu/vmess-menu.sh" "menu/vless-menu.sh" 
    "menu/trojan-menu.sh" "menu/system-menu.sh" "menu/backup-menu.sh" "menu/bot-menu.sh" 
    "menu/settings-menu.sh" "menu/info-menu.sh"
)
for file in "${FILES_MENU[@]}"; do download_file "$file" "$INSTALL_DIR/$file"; done

# --- SSH SCRIPTS ---
FILES_SSH=(
    "ssh/ssh-create.sh" "ssh/ssh-trial.sh" "ssh/ssh-renew.sh" "ssh/ssh-delete.sh" 
    "ssh/ssh-check.sh" "ssh/ssh-list.sh" "ssh/ssh-delete-expired.sh" "ssh/ssh-lock.sh" 
    "ssh/ssh-unlock.sh" "ssh/ssh-details.sh" "ssh/ssh-limit-ip.sh" "ssh/ssh-limit-quota.sh" 
    "ssh/setup-dropbear.sh" "ssh/setup-stunnel.sh" "ssh/setup-squid.sh" "ssh/setup-tuntap.sh"
    "ssh/setup-ws.sh" "ssh/setup-badvpn.sh"
)
for file in "${FILES_SSH[@]}"; do download_file "$file" "$INSTALL_DIR/$file"; done

# --- SYSTEM SCRIPTS ---
FILES_SYSTEM=(
    "system/check-services.sh" "system/monitor-vps.sh" "system/backup-now.sh" 
    "system/restore-backup.sh" "system/auto-backup.sh" "system/delete-expired.sh" 
    "system/setup-nginx.sh" "system/restart-all.sh" "system/restart-service.sh" 
    "system/speedtest.sh" "system/delete-all-expired.sh" "system/limit-speed.sh" 
    "system/monitor-service.sh" "system/check-logs.sh" "system/view-logs.sh" 
    "system/auto-reboot-settings.sh" "system/change-domain.sh" "system/change-banner.sh" 
    "system/change-port.sh" "system/change-timezone.sh" "system/fix-error-domain.sh" 
    "system/fix-error-proxy.sh" "system/renew-ssl.sh" "system/backup-ssl.sh" 
    "system/restore-ssl.sh" "system/auto-record-wildcard.sh" "system/limit-speed-settings.sh" 
    "system/reset-settings.sh" "system/enable-ssh-root.sh" "system/setup-rclone.sh" 
    "system/setup-rclone-manual.sh" "system/backup-online.sh" "system/restore-online.sh" 
    "system/auto-backup-online.sh"
)
for file in "${FILES_SYSTEM[@]}"; do download_file "$file" "$INSTALL_DIR/$file"; done

# --- BOT SCRIPTS ---
FILES_BOT=(
    "bot/telegram_bot.py" "bot/bot-setup.sh" "bot/bot-start.sh" "bot/bot-stop.sh" 
    "bot/bot-restart.sh" "bot/bot-status.sh" "bot/bot-auto-order.sh" "bot/bot-payment.sh" 
    "bot/bot-price.sh" "bot/bot-notification.sh" "bot/bot-test.sh"
)
for file in "${FILES_BOT[@]}"; do download_file "$file" "$INSTALL_DIR/$file"; done

# --- XRAY SCRIPTS ---
FILES_XRAY=( "xray/setup-xray.sh" "xray/placeholder.sh" )
# Add dynamic XRAY file lists
PROTOCOLS=("vmess" "vless" "trojan")
ACTIONS=("create" "trial" "list" "renew" "delete" "check" "delete-expired" "lock" "unlock" "details" "limit-ip" "limit-quota")

for proto in "${PROTOCOLS[@]}"; do
    for action in "${ACTIONS[@]}"; do
        FILES_XRAY+=("xray/${proto}-${action}.sh")
    done
done

for file in "${FILES_XRAY[@]}"; do download_file "$file" "$INSTALL_DIR/$file"; done

# --- ROOT/MAINTENANCE SCRIPTS ---
download_file "fix-install.sh" "$INSTALL_DIR/fix-install.sh"
download_file "update.sh" "$INSTALL_DIR/update.sh"
download_file "make-executable.sh" "$INSTALL_DIR/make-executable.sh"

# Set permissions
echo -e "${CYAN}[INFO]${NC} Setting permissions..."
chmod +x "$INSTALL_DIR"/*.sh
chmod +x "$INSTALL_DIR"/menu/*.sh
chmod +x "$INSTALL_DIR"/ssh/*.sh
chmod +x "$INSTALL_DIR"/system/*.sh
chmod +x "$INSTALL_DIR"/xray/*.sh
chmod +x "$INSTALL_DIR"/bot/*.sh

# Create global symlink for menu
ln -sf "$INSTALL_DIR/menu/main-menu.sh" /usr/bin/menu

# Setup SSH Services
echo -e "${CYAN}[INFO]${NC} Setting up Dropbear SSH..."
bash "$INSTALL_DIR/ssh/setup-dropbear.sh"

echo -e "${CYAN}[INFO]${NC} Setting up Stunnel4 SSL/TLS..."
bash "$INSTALL_DIR/ssh/setup-stunnel.sh"

echo -e "${CYAN}[INFO]${NC} Setting up Squid Proxy..."
bash "$INSTALL_DIR/ssh/setup-squid.sh"

# Setup TUN/TAP device and IP forwarding
echo -e "${CYAN}[INFO]${NC} Setting up TUN/TAP device for SSH tunneling..."
bash "$INSTALL_DIR/ssh/setup-tuntap.sh"

echo -e "${CYAN}[INFO]${NC} Setting up WebSocket-SSH..."
bash "$INSTALL_DIR/ssh/setup-ws.sh"

echo -e "${CYAN}[INFO]${NC} Setting up BadVPN UDP Gateway..."
bash "$INSTALL_DIR/ssh/setup-badvpn.sh"

# Install XRAY
echo -e "${CYAN}[INFO]${NC} Installing XRAY..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Setup SSL Certificate
echo -e "${CYAN}[INFO]${NC} Setting up SSL certificate..."
systemctl stop nginx

# Ask for Cloudflare API for Wildcard (Optional)
echo -e "${YELLOW}Do you want to enable Wildcard SSL for your domain?${NC}"
echo -e "${YELLOW}This requires Cloudflare API Token.${NC}"
read -p "Enable Wildcard SSL? (y/n): " wildcard_ssl

if [[ "$wildcard_ssl" == "y" ]]; then
    read -p "Enter Cloudflare Email: " cf_email
    read -p "Enter Cloudflare API Token: " cf_token
    
    if [[ -n "$cf_email" && -n "$cf_token" ]]; then
        echo -e "${CYAN}[INFO]${NC} Installing Cloudflare plugin..."
        pip3 install certbot-dns-cloudflare
        
        mkdir -p /root/.secrets
        echo "dns_cloudflare_email = $cf_email" > /root/.secrets/cloudflare.ini
        echo "dns_cloudflare_api_token = $cf_token" >> /root/.secrets/cloudflare.ini
        chmod 600 /root/.secrets/cloudflare.ini
        
        echo -e "${CYAN}[INFO]${NC} Requesting Wildcard Certificate..."
        certbot certonly --dns-cloudflare --dns-cloudflare-credentials /root/.secrets/cloudflare.ini \
            -d "$domain" -d "*.$domain" --agree-tos --email "$email" --non-interactive
    else
        echo -e "${RED}[ERROR]${NC} Missing Cloudflare credentials. Fallback to standard HTTP challenge."
        certbot certonly --standalone --preferred-challenges http --agree-tos --email "$email" -d "$domain" --non-interactive
    fi
else
    certbot certonly --standalone --preferred-challenges http --agree-tos --email "$email" -d "$domain" --non-interactive
fi

systemctl start nginx

# Link certificates
mkdir -p /etc/xray/certs
ln -sf /etc/letsencrypt/live/$domain/fullchain.pem /etc/xray/certs/fullchain.pem
ln -sf /etc/letsencrypt/live/$domain/privkey.pem /etc/xray/certs/privkey.pem

# Configure XRAY
echo -e "${CYAN}[INFO]${NC} Configuring XRAY..."
bash "$INSTALL_DIR/xray/setup-xray.sh"

# Configure cron jobs
echo "0 3 * * * root certbot renew --quiet --post-hook 'systemctl reload nginx'" > /etc/cron.d/ssl-renewal
echo "0 5 * * * root /sbin/reboot" > /etc/cron.d/auto-reboot
echo "0 0 * * * root $INSTALL_DIR/system/delete-expired.sh" > /etc/cron.d/delete-expired
echo "0 2 * * * root $INSTALL_DIR/system/auto-backup.sh" > /etc/cron.d/auto-backup

# Configure UFW
if ! command -v ufw &> /dev/null; then
    apt-get install -y ufw
fi
ufw --force enable

# TCP Ports
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 8080/tcp  # HTTP Alternate
ufw allow 8443/tcp  # HTTPS Alternate
ufw allow 2082/tcp  # Custom
ufw allow 2086/tcp  # Custom
ufw allow 2087/tcp  # Custom
ufw allow 2095/tcp  # Custom
ufw allow 2096/tcp  # Custom
ufw allow 3128/tcp  # Squid Proxy
ufw allow 7300/tcp  # BadVPN TCP
ufw allow 7300/udp  # BadVPN UDP
ufw allow 109/tcp   # Dropbear
ufw allow 110/tcp   # POP3
ufw allow 143/tcp   # IMAP
ufw allow 442/tcp   # Stunnel Dropbear
ufw allow 777/tcp   # Stunnel OpenSSH
ufw allow 53/udp    # DNS
ufw allow 1194/udp  # OpenVPN
ufw allow 7300/tcp  # Custom
ufw allow 109/tcp   # POP2
ufw allow 143/tcp   # IMAP
ufw allow 442/tcp   # Custom

# UDP Ports
ufw allow 53/udp    # DNS
ufw allow 443/udp   # QUIC/HTTP3
ufw allow 1194/udp  # OpenVPN
ufw allow 7300/udp  # Custom UDP

# Final setup
echo -e "${CYAN}[INFO]${NC} Finalizing installation..."
systemctl enable nginx
systemctl enable xray
systemctl enable fail2ban
systemctl restart nginx
systemctl restart xray

# Clean up
apt-get clean
apt-get autoremove -y

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}          INSTALLATION COMPLETED SUCCESSFULLY!        ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Domain       : ${NC}$domain"
echo -e "${YELLOW}IP Address   : ${NC}$(curl -s ifconfig.me)"
echo -e "${YELLOW}Install Date : ${NC}$(date +%Y-%m-%d)"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Type 'menu' to access the control panel${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
