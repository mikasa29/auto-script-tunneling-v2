#!/bin/bash

# OpenResty Installation Script
# This installs OpenResty (Nginx + Lua) for auto SSL certificate generation

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}      OpenResty Installation Script           ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} Please run as root"
    exit 1
fi

# Detect OS
OS_VERSION=$(lsb_release -sc)
echo -e "${CYAN}[INFO]${NC} Detected OS: Ubuntu $OS_VERSION"

# Install prerequisites
echo ""
echo -e "${CYAN}[INFO]${NC} Installing prerequisites..."
apt-get update
apt-get install -y wget gnupg ca-certificates lsb-release

# Add OpenResty APT repository
echo ""
echo -e "${CYAN}[INFO]${NC} Adding OpenResty repository..."
wget -O - https://openresty.org/package/pubkey.gpg | apt-key add -
echo "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/openresty.list

# Update package list
apt-get update

# Install OpenResty
echo ""
echo -e "${CYAN}[INFO]${NC} Installing OpenResty..."
apt-get install -y openresty openresty-opm

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} Failed to install OpenResty"
    exit 1
fi

# Install lua-resty-auto-ssl dependencies
echo ""
echo -e "${CYAN}[INFO]${NC} Installing lua-resty-auto-ssl dependencies..."
apt-get install -y \
    lua-resty-http \
    openssl \
    bash \
    curl

# Install dehydrated (ACME client)
echo ""
echo -e "${CYAN}[INFO]${NC} Installing dehydrated (ACME client)..."
wget https://raw.githubusercontent.com/dehydrated-io/dehydrated/master/dehydrated -O /usr/local/bin/dehydrated
chmod +x /usr/local/bin/dehydrated

# Install lua-resty-auto-ssl via OPM
echo ""
echo -e "${CYAN}[INFO]${NC} Installing lua-resty-auto-ssl..."
/usr/local/openresty/bin/opm get GUI/lua-resty-auto-ssl

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}[WARNING]${NC} Failed to install via OPM, trying manual installation..."
    
    # Manual installation fallback
    mkdir -p /usr/local/openresty/site/lualib/resty/auto-ssl
    cd /tmp
    wget https://github.com/auto-ssl/lua-resty-auto-ssl/archive/master.zip
    unzip -o master.zip
    cp -r lua-resty-auto-ssl-master/lib/resty/* /usr/local/openresty/site/lualib/resty/
    rm -rf master.zip lua-resty-auto-ssl-master
fi

# Create storage directory for auto SSL
echo ""
echo -e "${CYAN}[INFO]${NC} Creating auto SSL storage directory..."
mkdir -p /etc/resty-auto-ssl/storage
mkdir -p /etc/resty-auto-ssl/letsencrypt
chmod 700 /etc/resty-auto-ssl

# Create dehydrated config
echo ""
echo -e "${CYAN}[INFO]${NC} Configuring dehydrated..."
cat > /etc/resty-auto-ssl/dehydrated-config.sh << 'EOF'
#!/bin/bash
BASEDIR="/etc/resty-auto-ssl/letsencrypt"
HOOK="/usr/local/openresty/site/lualib/resty/auto-ssl/dehydrated_hooks.sh"
EOF

chmod +x /etc/resty-auto-ssl/dehydrated-config.sh

# Test OpenResty
echo ""
echo -e "${CYAN}[INFO]${NC} Testing OpenResty installation..."
/usr/local/openresty/bin/openresty -v

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}         Installation Successful!              ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}OpenResty:${NC}       Installed ✓"
    echo -e "${YELLOW}OPM:${NC}             Installed ✓"
    echo -e "${YELLOW}Auto SSL:${NC}        Installed ✓"
    echo -e "${YELLOW}Dehydrated:${NC}      Installed ✓"
    echo ""
    echo -e "${CYAN}Next Steps:${NC}"
    echo "  1. Configure OpenResty nginx.conf"
    echo "  2. Setup Cloudflare credentials"
    echo "  3. Migrate from standard Nginx"
    echo ""
else
    echo -e "${RED}[ERROR]${NC} OpenResty installation verification failed"
    exit 1
fi
