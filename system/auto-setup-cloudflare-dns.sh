#!/bin/bash

# Auto Setup Cloudflare DNS Records
# This script automatically creates A and CNAME records via Cloudflare API

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}      Auto Cloudflare DNS Setup              ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check arguments
if [ $# -lt 3 ]; then
    echo -e "${RED}[ERROR]${NC} Missing arguments"
    echo "Usage: $0 <domain> <cloudflare_email> <cloudflare_api_key>"
    exit 1
fi

DOMAIN=$1
CF_EMAIL=$2
CF_API_KEY=$3

# Detect VPS public IP
echo -e "${CYAN}[INFO]${NC} Detecting VPS public IP..."
VPS_IP=$(curl -s ifconfig.me)
if [ -z "$VPS_IP" ]; then
    VPS_IP=$(curl -s icanhazip.com)
fi

if [ -z "$VPS_IP" ]; then
    echo -e "${RED}[ERROR]${NC} Cannot detect VPS IP address"
    exit 1
fi

echo -e "${GREEN}✓${NC} VPS IP: $VPS_IP"

# Smart root domain extraction (universal approach)
if [[ $DOMAIN =~ \. ]]; then
    # Count domain parts
    PART_COUNT=$(echo "$DOMAIN" | awk -F. '{print NF}')
    
    if [ "$PART_COUNT" -ge 4 ]; then
        # 4+ parts: likely subdomain with multi-level TLD
        # Example: v6.muzakieid.my.id (4 parts) → muzakieid.my.id (last 3)
        #          sub.domain.co.uk (4 parts) → domain.co.uk (last 3)
        ROOT_DOMAIN=$(echo $DOMAIN | awk -F. '{print $(NF-2)"."$(NF-1)"."$NF}')
    elif [ "$PART_COUNT" -eq 3 ]; then
        # 3 parts: could be root with multi-level TLD OR subdomain with standard TLD
        # Check last part length - if 2 chars, likely multi-level TLD (co.uk, my.id)
        LAST_PART=$(echo $DOMAIN | awk -F. '{print $NF}')
        if [ "${#LAST_PART}" -eq 2 ]; then
            # Likely multi-level TLD: take all 3 parts
            # Example: muzakieid.my.id → muzakieid.my.id (all)
            ROOT_DOMAIN=$DOMAIN
        else
            # Standard TLD: take last 2 parts
            # Example: sub.domain.com → domain.com (last 2)
            ROOT_DOMAIN=$(echo $DOMAIN | awk -F. '{print $(NF-1)"."$NF}')
        fi
    else
        # 2 parts or less: already root domain
        ROOT_DOMAIN=$DOMAIN
    fi
else
    ROOT_DOMAIN=$DOMAIN
fi

echo -e "${CYAN}[INFO]${NC} Root domain: $ROOT_DOMAIN"

# Get Cloudflare Zone ID
echo -e "${CYAN}[INFO]${NC} Getting Cloudflare Zone ID..."
ZONE_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ROOT_DOMAIN" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_API_KEY" \
    -H "Content-Type: application/json")

ZONE_ID=$(echo $ZONE_RESPONSE | grep -Po '"id":"\K[^"]*' | head -1)

if [ -z "$ZONE_ID" ]; then
    echo -e "${RED}[ERROR]${NC} Cannot get Zone ID. Check:"
    echo "  - Cloudflare email & API key correct"
    echo "  - Domain $ROOT_DOMAIN exists in Cloudflare"
    exit 1
fi

echo -e "${GREEN}✓${NC} Zone ID: $ZONE_ID"

# Function to create/update A record
create_a_record() {
    local record_name=$1
    local ip=$2
    
    echo ""
    echo -e "${CYAN}[INFO]${NC} Creating A record: $record_name → $ip"
    
    # Check if record exists
    CHECK_RESPONSE=$(curl -s -X GET \
        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$record_name" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_API_KEY" \
        -H "Content-Type: application/json")
    
    RECORD_ID=$(echo $CHECK_RESPONSE | grep -Po '"id":"\K[^"]*' | head -1)
    
    if [ -n "$RECORD_ID" ]; then
        # Update existing record
        echo -e "${YELLOW}[INFO]${NC} Updating existing A record..."
        RESPONSE=$(curl -s -X PUT \
            "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
            -H "X-Auth-Email: $CF_EMAIL" \
            -H "X-Auth-Key: $CF_API_KEY" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"A\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}")
    else
        # Create new record
        RESPONSE=$(curl -s -X POST \
            "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
            -H "X-Auth-Email: $CF_EMAIL" \
            -H "X-Auth-Key: $CF_API_KEY" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"A\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}")
    fi
    
    if echo "$RESPONSE" | grep -q '"success":true'; then
        echo -e "${GREEN}✓${NC} A record created/updated successfully"
        return 0
    else
        echo -e "${RED}✗${NC} Failed to create A record"
        echo "$RESPONSE"
        return 1
    fi
}

# Function to create CNAME wildcard record
create_cname_record() {
    local record_name=$1
    local target=$2
    
    echo ""
    echo -e "${CYAN}[INFO]${NC} Creating CNAME record: $record_name → $target"
    
    # Check if record exists
    CHECK_RESPONSE=$(curl -s -X GET \
        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=CNAME&name=$record_name" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_API_KEY" \
        -H "Content-Type: application/json")
    
    RECORD_ID=$(echo $CHECK_RESPONSE | grep -Po '"id":"\K[^"]*' | head -1)
    
    if [ -n "$RECORD_ID" ]; then
        # Update existing record
        echo -e "${YELLOW}[INFO]${NC} Updating existing CNAME record..."
        RESPONSE=$(curl -s -X PUT \
            "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
            -H "X-Auth-Email: $CF_EMAIL" \
            -H "X-Auth-Key: $CF_API_KEY" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"CNAME\",\"name\":\"$record_name\",\"content\":\"$target\",\"ttl\":1,\"proxied\":false}")
    else
        # Create new record
        RESPONSE=$(curl -s -X POST \
            "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
            -H "X-Auth-Email: $CF_EMAIL" \
            -H "X-Auth-Key: $CF_API_KEY" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"CNAME\",\"name\":\"$record_name\",\"content\":\"$target\",\"ttl\":1,\"proxied\":false}")
    fi
    
    if echo "$RESPONSE" | grep -q '"success":true'; then
        echo -e "${GREEN}✓${NC} CNAME record created/updated successfully"
        return 0
    else
        echo -e "${RED}✗${NC} Failed to create CNAME record"
        echo "$RESPONSE"
        return 1
    fi
}

# Create A record for main domain
create_a_record "$DOMAIN" "$VPS_IP"

# Create CNAME wildcard record
create_cname_record "*.$DOMAIN" "$DOMAIN"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}      DNS Setup Complete!                     ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}DNS Records Created:${NC}"
echo -e "  A:     $DOMAIN → $VPS_IP"
echo -e "  CNAME: *.$DOMAIN → $DOMAIN"
echo ""
echo -e "${YELLOW}Note:${NC} DNS propagation may take 1-5 minutes"
echo ""
