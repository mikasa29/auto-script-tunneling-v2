#!/bin/bash

# Fix Corrupted XRAY Config
# Removes malformed users (starting with -e or containing spaces)

CONFIG_FILE="/usr/local/etc/xray/config.json"
BACKUP_FILE="/usr/local/etc/xray/config.json.bak_fix_$(date +%s)"

echo "=========================================="
echo "  Fix Corrupted XRAY Config"
echo "=========================================="

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found: $CONFIG_FILE"
    exit 1
fi

# 1. Backup Config
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "✓ Backup created: $BACKUP_FILE"

# 2. Remove malformed VMESS clients
# Email starting with -e or containing space
echo "🔍 Cleaning malformed entries..."

jq '
  .inbounds |= map(
    if .protocol == "vmess" then
      .settings.clients |= map(select(.email | test("^-e") | not)) |
      .settings.clients |= map(select(.email | test("\\s") | not))
    elif .protocol == "vless" then
      .settings.clients |= map(select(.email | test("^-e") | not)) |
      .settings.clients |= map(select(.email | test("\\s") | not))
    elif .protocol == "trojan" then
      .settings.clients |= map(select(.email | test("^-e") | not)) |
      .settings.clients |= map(select(.email | test("\\s") | not))
    else
      .
    end
  )
' "$BACKUP_FILE" > "$CONFIG_FILE"

if [ $? -eq 0 ]; then
    echo "✓ Config cleaned successfully"
else
    echo "❌ Failed to clean config (jq error)"
    cp "$BACKUP_FILE" "$CONFIG_FILE"
    exit 1
fi

# 3. Restart XRAY
echo "🔄 Restarting XRAY..."
systemctl restart xray

if systemctl is-active --quiet xray; then
    echo "✅ XRAY is RUNNING!"
    echo "Config has been fixed."
else
    echo "❌ XRAY failed to start."
    echo "Please check logs: journalctl -u xray -n 20"
fi
