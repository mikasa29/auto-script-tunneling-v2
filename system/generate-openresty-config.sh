#!/bin/bash

# OpenResty Nginx Configuration Template Generator
# This generates nginx.conf with Lua Auto SSL support

# Get domain from config
DOMAIN=$(cat /root/domain.txt 2>/dev/null || echo "yourdomain.com")

echo "Generating OpenResty configuration for domain: $DOMAIN"

# Create OpenResty nginx.conf
cat > /usr/local/openresty/nginx/conf/nginx.conf << EOF
# OpenResty Configuration with Lua Auto SSL
user www-data;
worker_processes auto;
pid /run/openresty.pid;

events {
    worker_connections 1024;
    multi_accept on;
}

http {
    # Basic Settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;
    
    include /usr/local/openresty/nginx/conf/mime.types;
    default_type application/octet-stream;
    
    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    
    # Logging
    access_log /var/log/openresty/access.log;
    error_log /var/log/openresty/error.log;
    
    # Gzip
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss;
    
    # Lua Package Path
    lua_package_path "/usr/local/openresty/site/lualib/?.lua;;";
    
    # Auto SSL Shared Dictionaries
    lua_shared_dict auto_ssl 1m;
    lua_shared_dict auto_ssl_settings 64k;
    
    # DNS Resolver
    resolver 8.8.8.8 8.8.4.4 ipv6=off;
    
    # Auto SSL Initialization
    init_by_lua_block {
        auto_ssl = (require "resty.auto-ssl").new()
        
        -- Domain whitelist for auto SSL
        auto_ssl:set("allow_domain", function(domain)
            -- Allow only subdomains of $DOMAIN
            return ngx.re.match(domain, "^.+\\.$DOMAIN\$", "ijo")
        end)
        
        -- Storage directory
        auto_ssl:set("dir", "/etc/resty-auto-ssl")
        
        -- Use HTTP-01 challenge (simpler than DNS)
        auto_ssl:set("request_domain", function(ssl, ssl_options)
            return ssl.server_name()
        end)
        
        auto_ssl:init()
    }
    
    init_worker_by_lua_block {
        auto_ssl:init_worker()
    }
    
    # HTTP Server for ACME Challenge
    server {
        listen 80;
        listen [::]:80;
        server_name _;
        
        # ACME challenge endpoint
        location /.well-known/acme-challenge/ {
            content_by_lua_block {
                auto_ssl:challenge_server()
            }
        }
        
        # Redirect all other traffic to HTTPS
        location / {
            return 301 https://\$host\$request_uri;
        }
    }
    
    # Port 89 HTTP Server (for compatibility)
    server {
        listen 89;
        listen [::]:89;
        server_name $DOMAIN *.$DOMAIN;
        
        root /var/www/html;
        index index.html index.htm index.php;
        
        location ~ \.php\$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php-fpm.sock;
        }
    }
    
    # HTTPS Server with Auto SSL
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name ~^.+\.$DOMAIN\$;
        
        # Dynamic SSL Certificate via Lua
        ssl_certificate_by_lua_block {
            auto_ssl:ssl_certificate()
        }
        
        # Fallback certificates (will be replaced by auto SSL)
        ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
        
        # Root directory
        root /var/www/html;
        index index.html index.htm index.php;
        
        # Log auto SSL requests for analytics
        log_by_lua_block {
            local ssl_name = ngx.var.ssl_server_name
            if ssl_name and ssl_name ~= "" then
                local log_file = io.open("/var/log/openresty/auto-ssl-requests.log", "a")
                if log_file then
                    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
                    local remote_ip = ngx.var.remote_addr
                    log_file:write(timestamp .. " | " .. ssl_name .. " | " .. remote_ip .. "\\n")
                    log_file:close()
                end
            end
        }
        
        # PHP Handler
        location ~ \.php\$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php-fpm.sock;
        }
        
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
    
    # Internal server for auto SSL hooks
    server {
        listen 127.0.0.1:8999;
        
        location / {
            content_by_lua_block {
                auto_ssl:hook_server()
            }
        }
    }
}
EOF

echo "OpenResty configuration generated successfully!"
echo "Config file: /usr/local/openresty/nginx/conf/nginx.conf"
