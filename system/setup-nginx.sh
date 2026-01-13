#!/bin/bash

# NGINX Configuration for VPN Server

DOMAIN=$(cat /root/domain.txt)

# Backup existing config
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# Main nginx config
cat > /etc/nginx/nginx.conf << 'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 768;
    multi_accept on;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF

# Create sites directory
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

# VPN Site config
cat > /etc/nginx/sites-available/vpn << EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 89;
    listen [::]:89;
    server_name $DOMAIN;
    root /var/www/html;
    index index.html index.htm;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    root /var/www/html;
    index index.html index.htm;

    # WebSocket for SSH
    location /ssh {
        proxy_pass http://127.0.0.1:700;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 86400;
    }

    # WebSocket for VMESS
    location /vmess {
        proxy_pass http://127.0.0.1:10001;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # WebSocket for VLESS
    location /vless {
        proxy_pass http://127.0.0.1:10002;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # WebSocket for TROJAN
    location /trojan {
        proxy_pass http://127.0.0.1:10003;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # Backup download
    location /backup {
        alias /etc/tunneling/backup;
        autoindex on;
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/vpn /etc/nginx/sites-enabled/

# Create landing page
mkdir -p /var/www/html
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VPN Server - $DOMAIN</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            max-width: 600px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            text-align: center;
        }
        h1 {
            color: #667eea;
            margin-bottom: 20px;
            font-size: 2.5em;
        }
        .status {
            display: inline-block;
            background: #10b981;
            color: white;
            padding: 10px 20px;
            border-radius: 50px;
            margin: 20px 0;
            font-weight: bold;
        }
        .info {
            text-align: left;
            margin: 30px 0;
            padding: 20px;
            background: #f3f4f6;
            border-radius: 10px;
        }
        .info h3 {
            color: #374151;
            margin-bottom: 15px;
        }
        .info ul {
            list-style: none;
            padding: 0;
        }
        .info li {
            padding: 10px;
            border-bottom: 1px solid #d1d5db;
        }
        .info li:last-child {
            border-bottom: none;
        }
        .footer {
            margin-top: 30px;
            color: #6b7280;
            font-size: 0.9em;
        }
        .telegram-btn {
            display: inline-block;
            background: #0088cc;
            color: white;
            padding: 15px 30px;
            border-radius: 50px;
            text-decoration: none;
            margin-top: 20px;
            font-weight: bold;
            transition: all 0.3s;
        }
        .telegram-btn:hover {
            background: #006699;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 VPN Server</h1>
        <div class="status">🟢 Online</div>
        
        <div class="info">
            <h3>📡 Server Information</h3>
            <ul>
                <li><strong>Domain:</strong> $DOMAIN</li>
                <li><strong>Status:</strong> Active</li>
                <li><strong>Protocols:</strong> SSH, VMESS, VLESS, TROJAN</li>
            </ul>
        </div>

        <div class="info">
            <h3>✨ Features</h3>
            <ul>
                <li>✅ High Speed Connection</li>
                <li>✅ 99.9% Uptime</li>
                <li>✅ Multiple Protocol</li>
                <li>✅ 24/7 Support</li>
                <li>✅ Auto Order via Bot</li>
            </ul>
        </div>

        <a href="https://t.me/yourvpnbot" class="telegram-btn">
            📱 Order via Telegram Bot
        </a>

        <div class="footer">
            <p>© 2024 AUTOSCRIPT TUNNELING. All rights reserved.</p>
            <p>Powered by XRAY & NGINX</p>
        </div>
    </div>
</body>
</html>
EOF

# Test nginx config
nginx -t

if [ $? -eq 0 ]; then
    systemctl reload nginx
    echo "Nginx configured successfully!"
else
    echo "Nginx configuration error!"
    exit 1
fi
