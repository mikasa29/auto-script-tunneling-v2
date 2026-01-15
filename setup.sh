#!/bin/bash
# =========================================
# AUTOSCRIPT TUNNELING VPN
# Support: Ubuntu 22.04+ / Debian 11+
# Author: AUTOSCRIPT TUNNELING TEAM
# =========================================

# Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

# Check OS
if [[ -e /etc/debian_version ]]; then
    OS="debian"
    source /etc/os-release
    VER=$VERSION_ID
    if [[ "$ID" == "debian" && "$VER" -lt 11 ]]; then
        echo -e "${RED}Your Debian version is not supported. Minimum Debian 11${NC}"
        exit 1
    elif [[ "$ID" == "ubuntu" && "$VER" < "22.04" ]]; then
        echo -e "${RED}Your Ubuntu version is not supported. Minimum Ubuntu 22.04${NC}"
        exit 1
    fi
else
    echo -e "${RED}This OS is not supported${NC}"
    exit 1
fi

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}         AUTOSCRIPT TUNNELING VPN INSTALLER         ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}         • Support Ubuntu 22.04+ / Debian 11+       ${NC}"
echo -e "${YELLOW}         • Optimized for 1GB RAM / 1 CPU Core       ${NC}"
echo -e "${YELLOW}         • All Files Unlocked (Editable)            ${NC}"
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

# Get email for SSL
read -p "Enter your email for SSL certificate: " email
if [[ -z $email ]]; then
    email="admin@${domain}"
fi

echo ""
echo -e "${GREEN}Starting installation...${NC}"
sleep 2

# Update and install dependencies
echo -e "${CYAN}[INFO]${NC} Updating system..."
apt-get update -y
apt-get upgrade -y

echo -e "${CYAN}[INFO]${NC} Installing dependencies..."
apt-get install -y \
    curl \
    wget \
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

# Create directories
echo -e "${CYAN}[INFO]${NC} Creating directories..."
mkdir -p /etc/tunneling
mkdir -p /etc/tunneling/ssh
mkdir -p /etc/tunneling/xray
mkdir -p /etc/tunneling/vmess
mkdir -p /etc/tunneling/vless
mkdir -p /etc/tunneling/trojan
mkdir -p /etc/tunneling/backup
mkdir -p /etc/tunneling/bot
mkdir -p /var/log/tunneling
mkdir -p /usr/local/sbin/tunneling

# Save installation info
cat > /etc/tunneling/config.json << EOF
{
    "domain": "$domain",
    "email": "$email",
    "install_date": "$(date +%Y-%m-%d)",
    "version": "1.0.0",
    "status": "active"
}
EOF

# Download and install components
echo -e "${CYAN}[INFO]${NC} Downloading components..."
cd /usr/local/sbin/tunneling

# Base URL for scripts
BASE_URL="https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling-v2/main"
INSTALL_DIR="/usr/local/sbin/tunneling"

# Create installation directory
mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/menu"
mkdir -p "$INSTALL_DIR/ssh"
mkdir -p "$INSTALL_DIR/system"
mkdir -p "$INSTALL_DIR/xray"
mkdir -p "$INSTALL_DIR/bot"

# Function to install files
install_file() {
    local source_path="$1"
    local dest_path="$2"
    local filename=$(basename "$source_path")
    
    if [[ -f "$source_path" ]]; then
        # Copy from local if exists (Instalasi dari git clone)
        cp "$source_path" "$dest_path"
    else
        # Download if local file not found (Instalasi remote/curl)
        echo -e "${YELLOW}[WARNING] Local file $source_path not found, downloading...${NC}"
        wget -q -O "$dest_path" "${BASE_URL}/$source_path" 2>/dev/null || curl -sL "${BASE_URL}/$source_path" -o "$dest_path"
    fi
}

# Install menu scripts
echo -e "${CYAN}[INFO]${NC} Installing menu scripts..."
for file in menu/*.sh; do install_file "$file" "$INSTALL_DIR/menu/$(basename "$file")"; done
install_file "menu/main-menu.sh" "$INSTALL_DIR/main-menu.sh" # Main menu di root tunneling juga oke, atau symlink

# Install SSH scripts
echo -e "${CYAN}[INFO]${NC} Installing SSH scripts..."
for file in ssh/*.sh; do install_file "$file" "$INSTALL_DIR/ssh/$(basename "$file")"; done

# Install system scripts
echo -e "${CYAN}[INFO]${NC} Installing system scripts..."
for file in system/*.sh; do install_file "$file" "$INSTALL_DIR/system/$(basename "$file")"; done
for file in *.sh; do 
    if [[ "$file" == "setup.sh" ]]; then continue; fi
    install_file "$file" "$INSTALL_DIR/$(basename "$file")" 2>/dev/null
done

# Install XRAY scripts
echo -e "${CYAN}[INFO]${NC} Installing XRAY scripts..."
for file in xray/*.sh; do install_file "$file" "$INSTALL_DIR/xray/$(basename "$file")"; done

# Install bot scripts
echo -e "${CYAN}[INFO]${NC} Installing bot scripts..."
for file in bot/*.sh; do install_file "$file" "$INSTALL_DIR/bot/$(basename "$file")"; done
if [[ -f "bot/telegram_bot.py" ]]; then
    cp "bot/telegram_bot.py" "$INSTALL_DIR/bot/telegram_bot.py"
else
     wget -q -O "$INSTALL_DIR/bot/telegram_bot.py" "${BASE_URL}/bot/telegram_bot.py" 2>/dev/null
fi

# Set permissions
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

# Install XRAY
echo -e "${CYAN}[INFO]${NC} Installing XRAY..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Setup SSL Certificate
echo -e "${CYAN}[INFO]${NC} Setting up SSL certificate..."
systemctl stop nginx
certbot certonly --standalone --preferred-challenges http --agree-tos --email $email -d $domain
systemctl start nginx

# Link certificates
mkdir -p /etc/xray/certs
ln -sf /etc/letsencrypt/live/$domain/fullchain.pem /etc/xray/certs/fullchain.pem
ln -sf /etc/letsencrypt/live/$domain/privkey.pem /etc/xray/certs/privkey.pem

# Configure XRAY
echo -e "${CYAN}[INFO]${NC} Configuring XRAY..."
bash "$INSTALL_DIR/xray/setup-xray.sh"

# Configure cron for SSL renewal
echo "0 3 * * * root certbot renew --quiet --post-hook 'systemctl reload nginx'" > /etc/cron.d/ssl-renewal

# Setup auto reboot
echo "0 5 * * * root /sbin/reboot" > /etc/cron.d/auto-reboot

# Setup auto delete expired accounts
echo "0 0 * * * root $INSTALL_DIR/system/delete-expired.sh" > /etc/cron.d/delete-expired

# Setup auto backup
echo "0 2 * * * root $INSTALL_DIR/system/auto-backup.sh" > /etc/cron.d/auto-backup

# Configure firewall
echo -e "${CYAN}[INFO]${NC} Configuring firewall..."

# Install UFW if not installed
if ! command -v ufw &> /dev/null; then
    echo -e "${CYAN}[INFO]${NC} Installing UFW..."
    apt-get install -y ufw
fi

# Configure UFW
ufw --force enable
ufw allow 22/tcp    # OpenSSH
ufw allow 80/tcp    # HTTP (Nginx)
ufw allow 109/tcp   # Dropbear SSH
ufw allow 143/tcp   # Dropbear SSH
ufw allow 442/tcp   # Stunnel (Dropbear SSL)
ufw allow 443/tcp   # HTTPS (Nginx + XRAY)
ufw allow 700/tcp   # WebSocket SSH
ufw allow 777/tcp   # Stunnel (OpenSSH SSL)
ufw allow 3128/tcp  # Squid Proxy
ufw allow 7300/tcp  # BadVPN TCP
ufw allow 7300/udp  # BadVPN UDP
ufw allow 8080/tcp  # Squid Proxy
ufw allow 8443/tcp  # HTTPS Alternate
ufw reload

# Sudah dibuat symlink menu di line 208, tidak perlu dobel

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
rm -f setup.sh
