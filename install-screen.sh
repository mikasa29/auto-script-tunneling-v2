#!/bin/bash
# =========================================
# AUTOSCRIPT TUNNELING VPN INSTALLER WITH SCREEN
# Support: Ubuntu 22.04+ / Debian 11+
# Description: Runs installation in screen session to prevent interruption
# =========================================

# Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

# Install screen if not already installed
if ! command -v screen &> /dev/null; then
    echo -e "${CYAN}[INFO]${NC} Installing screen..."
    apt-get update -qq
    apt-get install -y screen
fi

# Session name
SESSION_NAME="autoscript-install"

# Check if installation is already running
if screen -list | grep -q "$SESSION_NAME"; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Installation is already running in screen session!${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "To attach to the session, run:"
    echo -e "${GREEN}screen -r $SESSION_NAME${NC}"
    echo ""
    echo -e "To list all screen sessions:"
    echo -e "${GREEN}screen -ls${NC}"
    exit 0
fi

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}   AUTOSCRIPT TUNNELING VPN INSTALLER (with Screen) ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Installation will run in a screen session.${NC}"
echo -e "${YELLOW}You can safely disconnect and reconnect later.${NC}"
echo ""

# Get domain
read -p "Enter your domain: " domain
if [[ -z $domain ]]; then
    echo -e "${RED}Domain cannot be empty!${NC}"
    exit 1
fi

# Get email
read -p "Enter your email for SSL certificate (press Enter for default): " email
if [[ -z $email ]]; then
    email="admin@${domain}"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Starting installation in screen session...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Installation details:"
echo -e "  Domain : ${GREEN}$domain${NC}"
echo -e "  Email  : ${GREEN}$email${NC}"
echo -e "  Session: ${GREEN}$SESSION_NAME${NC}"
echo ""
echo -e "Commands to manage the session:"
echo -e "  • Attach to session : ${GREEN}screen -r $SESSION_NAME${NC}"
echo -e "  • Detach from screen: ${GREEN}Ctrl+A then D${NC}"
echo -e "  • List sessions     : ${GREEN}screen -ls${NC}"
echo -e "  • View logs         : ${GREEN}tail -f /var/log/autoscript-install.log${NC}"
echo ""

# Ask to start now or in screen
read -p "Press Enter to start installation in screen session... " dummy

# Download install.sh
echo -e "${CYAN}[INFO]${NC} Downloading installer..."
cd /tmp
rm -f install.sh
wget -q -O install.sh https://github.com/mikasa29/auto-script-tunneling-v2/main/install.sh
chmod +x install.sh

# Create installation script that will run in screen
cat > /tmp/run-install.sh << EOF
#!/bin/bash
exec &> >(tee -a /var/log/autoscript-install.log)
echo "Installation started at: \$(date)"
echo "Domain: $domain"
echo "Email: $email"
echo ""

# Pass answers to install.sh
/tmp/install.sh << ANSWERS
$domain
$email
ANSWERS

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installation completed at: \$(date)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "You can safely exit this screen session by pressing: Ctrl+A then D"
echo "Or just close your SSH connection, the screen will keep running."
echo ""
echo "Press Enter to exit screen session..."
read
EOF

chmod +x /tmp/run-install.sh

# Start installation in screen
screen -dmS "$SESSION_NAME" bash /tmp/run-install.sh

sleep 2

echo ""
echo -e "${GREEN}✓ Installation started in screen session!${NC}"
echo ""
echo -e "The installation is now running in background."
echo -e "You can:"
echo -e "  1. Attach to watch progress: ${GREEN}screen -r $SESSION_NAME${NC}"
echo -e "  2. Disconnect SSH safely - installation will continue"
echo -e "  3. Check logs: ${GREEN}tail -f /var/log/autoscript-install.log${NC}"
echo ""
echo -e "To reconnect to the session after SSH disconnect:"
echo -e "  ${GREEN}screen -r $SESSION_NAME${NC}"
echo ""

# Ask if user wants to attach now
read -p "Do you want to attach to the session now? (y/n): " attach
if [[ $attach == "y" || $attach == "Y" ]]; then
    echo ""
    echo -e "${YELLOW}Attaching to screen session...${NC}"
    echo -e "${YELLOW}To detach: Press Ctrl+A, then press D${NC}"
    sleep 2
    screen -r "$SESSION_NAME"
else
    echo ""
    echo -e "${GREEN}Installation is running in background.${NC}"
    echo -e "Attach later with: ${GREEN}screen -r $SESSION_NAME${NC}"
    echo ""
fi
