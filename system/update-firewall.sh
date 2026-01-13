#!/bin/bash
# =========================================
# UPDATE FIREWALL RULES
# Add UDP support and organize rules
# =========================================

# Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}           UPDATE FIREWALL RULES                    ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if UFW is installed
if ! command -v ufw &> /dev/null; then
    echo -e "${YELLOW}[INFO]${NC} Installing UFW..."
    apt-get update
    apt-get install -y ufw
fi

# Backup current rules
echo -e "${CYAN}[INFO]${NC} Backing up current firewall rules..."
ufw status numbered > /root/ufw-backup-$(date +%Y%m%d-%H%M%S).txt

# Reset UFW (optional - comment out if you want to keep existing rules)
# echo -e "${YELLOW}[WARNING]${NC} Resetting UFW rules..."
# ufw --force reset

echo -e "${CYAN}[INFO]${NC} Adding firewall rules..."

# Enable UFW
ufw --force enable

# TCP Ports
echo -e "${GREEN}[✓]${NC} Configuring TCP ports..."
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
ufw allow 7300/tcp  # Custom
ufw allow 109/tcp   # POP2
ufw allow 110/tcp   # POP3
ufw allow 143/tcp   # IMAP
ufw allow 442/tcp   # Stunnel Dropbear
ufw allow 777/tcp   # Stunnel OpenSSH

# UDP Ports
echo -e "${GREEN}[✓]${NC} Configuring UDP ports..."
ufw allow 53/udp    # DNS
ufw allow 443/udp   # QUIC/HTTP3
ufw allow 1194/udp  # OpenVPN
ufw allow 7300/udp  # Custom UDP

# Allow established connections
ufw allow in on lo
ufw allow out on lo

# Set default policies
ufw default deny incoming
ufw default allow outgoing

# Reload UFW
ufw reload

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}           FIREWALL RULES UPDATED                   ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}TCP Ports Opened:${NC}"
echo "  • SSH          : 22"
echo "  • HTTP         : 80, 8080"
echo "  • HTTPS        : 443, 8443"
echo "  • Squid Proxy  : 3128"
echo "  • Custom       : 2082, 2086, 2087, 2095, 2096, 7300"
echo "  • Email        : 109, 110, 143"
echo "  • Stunnel      : 442, 777"
echo ""
echo -e "${GREEN}UDP Ports Opened:${NC}"
echo "  • DNS          : 53"
echo "  • QUIC/HTTP3   : 443"
echo "  • OpenVPN      : 1194"
echo "  • Custom       : 7300"
echo ""
echo -e "${CYAN}Current Firewall Status:${NC}"
ufw status numbered
echo ""
echo -e "${YELLOW}Note:${NC} Backup saved to /root/ufw-backup-*.txt"
echo ""
