#!/bin/bash

# Auto SSL Analytics Script
# View top bug hosts from auto SSL requests log

LOG_FILE="/var/log/openresty/auto-ssl-requests.log"

# Color codes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}     Auto SSL Request Analytics              ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ ! -f "$LOG_FILE" ]; then
    echo -e "${YELLOW}[INFO]${NC} No log file found yet."
    echo "Log will be created when first auto SSL request happens."
    exit 0
fi

# Total requests
TOTAL=$(wc -l < "$LOG_FILE")
echo -e "${YELLOW}Total SSL Requests:${NC} $TOTAL"
echo ""

# Top 20 Bug Hosts
echo -e "${CYAN}Top 20 Bug Hosts:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-6s %-50s\n" "Count" "Domain"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

awk -F' \\| ' '{print $2}' "$LOG_FILE" | \
    sort | uniq -c | sort -rn | head -20 | \
    while read count domain; do
        printf "${GREEN}%-6s${NC} %-50s\n" "$count" "$domain"
    done

echo ""

# Recent requests (last 10)
echo -e "${CYAN}Recent Requests (Last 10):${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
tail -10 "$LOG_FILE" | while IFS='|' read timestamp domain ip; do
    echo -e "${YELLOW}$timestamp${NC} - $domain"
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Tip:${NC} Pre-warm top bugs dengan /addbug untuk instant first connection"
echo "Example: /addbug $(awk -F' \\| ' '{print $2}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')"
