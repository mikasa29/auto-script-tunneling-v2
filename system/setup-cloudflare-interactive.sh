#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}      MANUAL CLOUDFLARE SSL SETUP WIZARD           ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get Domain
if [ -f /root/domain.txt ]; then
    DEFAULT_DOMAIN=$(cat /root/domain.txt)
    echo -e "Detected domain: ${GREEN}${DEFAULT_DOMAIN}${NC}"
    read -p "Use this domain? [Y/n]: " use_default
    if [[ "$use_default" =~ ^[Nn]$ ]]; then
        read -p "Enter your domain: " domain
    else
        domain=$DEFAULT_DOMAIN
    fi
else
    read -p "Enter your domain: " domain
fi

if [[ -z $domain ]]; then
    echo -e "${RED}Domain cannot be empty!${NC}"
    exit 1
fi
echo "$domain" > /root/domain.txt

# Get Email
if [ -f /root/email.txt ]; then
    email=$(cat /root/email.txt)
else
    email="admin@${domain}"
fi

echo -e ""
echo -e "${CYAN}Select Cloudflare Authentication Method:${NC}"
echo -e "  ${YELLOW}1)${NC} API Token (Recommended - More Secure)"
echo -e "  ${YELLOW}2)${NC} Global API Key (Legacy)"
echo ""
read -p "Choose [1 or 2]: " cf_method

if [[ "$cf_method" == "1" ]]; then
    # API Token Method (Recommended)
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}API Token Setup Instructions:${NC}"
    echo -e "${YELLOW}1.${NC} Go to https://dash.cloudflare.com/profile/api-tokens"
    echo -e "${YELLOW}2.${NC} Click 'Create Token'"
    echo -e "${YELLOW}3.${NC} Use 'Edit zone DNS' template"
    echo -e "${YELLOW}4.${NC} Select your domain in Zone Resources"
    echo -e "${YELLOW}5.${NC} Create and copy the token"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "Enter Cloudflare API Token: " cf_token
    
    if [[ -n "$cf_token" ]]; then
        echo -e "${CYAN}[INFO]${NC} Installing Cloudflare DNS plugin..."
        # Install with pinned versions to avoid deprecation warnings
        if apt-get install -y python3-certbot-dns-cloudflare 2>/dev/null; then
            echo -e "${GREEN}Installed via apt${NC}"
            # Downgrade cloudflare package to stable version to avoid warnings
            echo -e "${YELLOW}Downgrading cloudflare package to stable version...${NC}"
            pip3 install --upgrade cloudflare==2.19.4 --break-system-packages 2>/dev/null || \
            pip3 install --upgrade cloudflare==2.19.4
        else
            echo -e "${YELLOW}Installing via pip with stable versions...${NC}"
            pip3 install certbot-dns-cloudflare cloudflare==2.19.4 --break-system-packages 2>/dev/null || \
            pip3 install certbot-dns-cloudflare cloudflare==2.19.4
        fi
        
        mkdir -p /root/.secrets
        echo "# Cloudflare API Token" > /root/.secrets/cloudflare.ini
        echo "dns_cloudflare_api_token = $cf_token" >> /root/.secrets/cloudflare.ini
        chmod 600 /root/.secrets/cloudflare.ini
        
        echo -e "${CYAN}[INFO]${NC} Requesting Wildcard Certificate (*.${domain})..."
        # Added --cert-name to force overwrite existing single-domain cert
        if certbot certonly --dns-cloudflare --dns-cloudflare-credentials /root/.secrets/cloudflare.ini \
            -d "$domain" -d "*.$domain" --cert-name "$domain" --agree-tos --email "$email" --non-interactive --dns-cloudflare-propagation-seconds 30; then
            echo -e "${GREEN}[SUCCESS]${NC} Wildcard SSL certificate installed successfully!"
            echo "$cf_token" > /root/cloudflare-token.txt
        else
            echo -e "${RED}[ERROR]${NC} Wildcard certificate request failed!"
            exit 1
        fi
    else
        echo -e "${RED}[ERROR]${NC} API Token is empty."
        exit 1
    fi
    
elif [[ "$cf_method" == "2" ]]; then
    # Global API Key Method (Legacy)
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Global API Key Setup:${NC}"
    echo -e "1. Go to https://dash.cloudflare.com/profile/api-tokens"
    echo -e "2. Scroll to 'API Keys' section"
    echo -e "3. Click 'View' on Global API Key"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "Enter Cloudflare Email: " cf_email
    read -p "Enter Global API Key: " cf_api_key
    
    if [[ -n "$cf_email" && -n "$cf_api_key" ]]; then
        echo -e "${CYAN}[INFO]${NC} Installing Cloudflare DNS plugin..."
        # Install with pinned versions to avoid deprecation warnings
        if apt-get install -y python3-certbot-dns-cloudflare 2>/dev/null; then
            echo -e "${GREEN}Installed via apt${NC}"
            # Downgrade cloudflare package to stable version to avoid warnings
            echo -e "${YELLOW}Downgrading cloudflare package to stable version...${NC}"
            pip3 install --upgrade cloudflare==2.19.4 --break-system-packages 2>/dev/null || \
            pip3 install --upgrade cloudflare==2.19.4
        else
            echo -e "${YELLOW}Installing via pip with stable versions...${NC}"
            pip3 install certbot-dns-cloudflare cloudflare==2.19.4 --break-system-packages 2>/dev/null || \
            pip3 install certbot-dns-cloudflare cloudflare==2.19.4
        fi
        
        mkdir -p /root/.secrets
        echo "# Cloudflare Global API Key" > /root/.secrets/cloudflare.ini
        echo "dns_cloudflare_email = $cf_email" >> /root/.secrets/cloudflare.ini
        echo "dns_cloudflare_api_key = $cf_api_key" >> /root/.secrets/cloudflare.ini
        chmod 600 /root/.secrets/cloudflare.ini
        
        # Auto-setup DNS records
        echo -e "${CYAN}[INFO]${NC} Setting up DNS records via Cloudflare API..."
        /usr/local/sbin/tunneling/system/auto-setup-cloudflare-dns.sh "$domain" "$cf_email" "$cf_api_key"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[✓]${NC} DNS records configured automatically"
            echo -e "${YELLOW}Waiting 10s for DNS propagation...${NC}"
            sleep 10
        else
            echo -e "${YELLOW}[WARNING]${NC} DNS auto-setup failed. Please configure manually."
        fi
        
        echo -e "${CYAN}[INFO]${NC} Requesting Wildcard Certificate (*.${domain})..."
        # Added --cert-name to force overwrite existing single-domain cert
        if certbot certonly --dns-cloudflare --dns-cloudflare-credentials /root/.secrets/cloudflare.ini \
            -d "$domain" -d "*.$domain" --cert-name "$domain" --agree-tos --email "$email" --non-interactive --dns-cloudflare-propagation-seconds 30; then
            echo -e "${GREEN}[SUCCESS]${NC} Wildcard SSL certificate installed successfully!"
        else
            echo -e "${RED}[ERROR]${NC} Wildcard certificate request failed!"
            exit 1
        fi
    else
        echo -e "${RED}[ERROR]${NC} Missing credentials."
        exit 1
    fi
else
    echo -e "${RED}Invalid option!${NC}"
    exit 1
fi

# Update Link certificates to XRAY
echo -e "${CYAN}[INFO]${NC} Updating Certificates..."
mkdir -p /etc/xray/certs
ln -sf /etc/letsencrypt/live/$domain/fullchain.pem /etc/xray/certs/fullchain.pem
ln -sf /etc/letsencrypt/live/$domain/privkey.pem /etc/xray/certs/privkey.pem

# Restart services
echo -e "${CYAN}[INFO]${NC} Restarting Services..."
if pgrep nginx > /dev/null; then
    systemctl restart nginx
fi
if pgrep xray > /dev/null; then
    systemctl restart xray
fi
echo -e "${GREEN}[SUCCESS]${NC} Setup Completed! Wildcard SSL is active."
