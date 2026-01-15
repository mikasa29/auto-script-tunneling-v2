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
    server_name $DOMAIN *.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 89;
    listen [::]:89;
    server_name $DOMAIN *.$DOMAIN;
    root /var/www/html;
    index index.html index.htm;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN *.$DOMAIN;

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
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
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
            max-width: 900px;
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
        .metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 30px 0;
        }
        .metric-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        .metric-card h4 {
            font-size: 0.9em;
            opacity: 0.9;
            margin-bottom: 10px;
        }
        .metric-card .value {
            font-size: 2em;
            font-weight: bold;
        }
        .metric-card .unit {
            font-size: 0.8em;
            opacity: 0.8;
        }
        .chart-container {
            margin: 30px 0;
            padding: 20px;
            background: #f3f4f6;
            border-radius: 10px;
            height: 300px;
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
        .loading {
            color: #6b7280;
            font-style: italic;
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

        <h3 style="color: #374151; margin-top: 30px;">📊 Real-time System Metrics</h3>
        <div class="metrics">
            <div class="metric-card">
                <h4>🖥️ CPU Usage</h4>
                <div class="value" id="cpu">--</div>
                <div class="unit">%</div>
            </div>
            <div class="metric-card">
                <h4>💾 RAM Usage</h4>
                <div class="value" id="ram">--</div>
                <div class="unit">MB</div>
            </div>
            <div class="metric-card">
                <h4>💽 Disk I/O</h4>
                <div class="value" id="disk">--</div>
                <div class="unit">MB/s</div>
            </div>
            <div class="metric-card">
                <h4>🌐 Network</h4>
                <div class="value" id="network">--</div>
                <div class="unit">Mbit/s</div>
            </div>
        </div>

        <div class="chart-container">
            <canvas id="metricsChart"></canvas>
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
            <p>© 2026 Muzakie ID. All rights reserved.</p>
            <p>Powered by XRAY & NGINX</p>
        </div>
    </div>

    <script>
        // Initialize chart
        const ctx = document.getElementById('metricsChart');
        const maxDataPoints = 20;
        const chartData = {
            labels: [],
            datasets: [
                {
                    label: 'CPU %',
                    data: [],
                    borderColor: 'rgb(255, 99, 132)',
                    backgroundColor: 'rgba(255, 99, 132, 0.1)',
                    tension: 0.4
                },
                {
                    label: 'RAM %',
                    data: [],
                    borderColor: 'rgb(54, 162, 235)',
                    backgroundColor: 'rgba(54, 162, 235, 0.1)',
                    tension: 0.4
                },
                {
                    label: 'Disk I/O MB/s',
                    data: [],
                    borderColor: 'rgb(255, 206, 86)',
                    backgroundColor: 'rgba(255, 206, 86, 0.1)',
                    tension: 0.4
                },
                {
                    label: 'Network Mbit/s',
                    data: [],
                    borderColor: 'rgb(75, 192, 192)',
                    backgroundColor: 'rgba(75, 192, 192, 0.1)',
                    tension: 0.4
                }
            ]
        };

        const chart = new Chart(ctx, {
            type: 'line',
            data: chartData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        position: 'top'
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100
                    }
                }
            }
        });

        // Fetch and update metrics
        async function updateMetrics() {
            try {
                const response = await fetch('/metrics.php');
                const data = await response.json();
                
                // Update cards
                document.getElementById('cpu').textContent = data.cpu.toFixed(1);
                document.getElementById('ram').textContent = data.ram_used.toFixed(0);
                document.getElementById('disk').textContent = data.disk_io.toFixed(2);
                document.getElementById('network').textContent = data.network.toFixed(2);
                
                // Update chart
                const now = new Date().toLocaleTimeString();
                chartData.labels.push(now);
                chartData.datasets[0].data.push(data.cpu);
                chartData.datasets[1].data.push(data.ram_percent);
                chartData.datasets[2].data.push(data.disk_io);
                chartData.datasets[3].data.push(data.network);
                
                // Keep only last 20 data points
                if (chartData.labels.length > maxDataPoints) {
                    chartData.labels.shift();
                    chartData.datasets.forEach(dataset => dataset.data.shift());
                }
                
                chart.update('none');
            } catch (error) {
                console.error('Error fetching metrics:', error);
            }
        }

        // Update every 2 seconds
        updateMetrics();
        setInterval(updateMetrics, 2000);
    </script>
</body>
</html>
EOF

# Create metrics API
cat > /var/www/html/metrics.php << 'EOFPHP'
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Get CPU usage
function getCpuUsage() {
    \$stat1 = file('/proc/stat');
    sleep(1);
    \$stat2 = file('/proc/stat');
    
    \$info1 = explode(" ", preg_replace("!cpu +!", "", \$stat1[0]));
    \$info2 = explode(" ", preg_replace("!cpu +!", "", \$stat2[0]));
    
    \$dif = array();
    \$dif['user'] = \$info2[0] - \$info1[0];
    \$dif['nice'] = \$info2[1] - \$info1[1];
    \$dif['sys'] = \$info2[2] - \$info1[2];
    \$dif['idle'] = \$info2[3] - \$info1[3];
    \$total = array_sum(\$dif);
    \$cpu = 100 - (\$dif['idle'] * 100 / \$total);
    
    return round(\$cpu, 2);
}

// Get RAM usage
function getRamUsage() {
    \$free = shell_exec('free -m');
    \$free = (string)trim(\$free);
    \$free_arr = explode("\n", \$free);
    \$mem = explode(" ", \$free_arr[1]);
    \$mem = array_filter(\$mem);
    \$mem = array_merge(\$mem);
    
    return array(
        'total' => (float)\$mem[1],
        'used' => (float)\$mem[2],
        'free' => (float)\$mem[3],
        'percent' => round((\$mem[2] / \$mem[1]) * 100, 2)
    );
}

// Get Disk I/O
function getDiskIO() {
    \$output = shell_exec("iostat -d -m 1 2 | tail -n 2 | head -n 1 | awk '{print \$3+\$4}'");
    return round((float)trim(\$output), 2);
}

// Get Network bandwidth
function getNetworkBandwidth() {
    \$interface = trim(shell_exec("ip route | grep default | awk '{print \$5}' | head -n1"));
    if (empty(\$interface)) {
        return 0;
    }
    
    \$rx1 = (float)file_get_contents("/sys/class/net/\$interface/statistics/rx_bytes");
    \$tx1 = (float)file_get_contents("/sys/class/net/\$interface/statistics/tx_bytes");
    sleep(1);
    \$rx2 = (float)file_get_contents("/sys/class/net/\$interface/statistics/rx_bytes");
    \$tx2 = (float)file_get_contents("/sys/class/net/\$interface/statistics/tx_bytes");
    
    \$rx = (\$rx2 - \$rx1) * 8 / 1000000; // Convert to Mbit/s
    \$tx = (\$tx2 - \$tx1) * 8 / 1000000;
    
    return round(\$rx + \$tx, 2);
}

\$ram = getRamUsage();

\$metrics = array(
    'cpu' => getCpuUsage(),
    'ram_total' => \$ram['total'],
    'ram_used' => \$ram['used'],
    'ram_free' => \$ram['free'],
    'ram_percent' => \$ram['percent'],
    'disk_io' => getDiskIO(),
    'network' => getNetworkBandwidth(),
    'timestamp' => time()
);

echo json_encode(\$metrics);
?>
EOFPHP

# Install PHP if not exists
if ! command -v php &> /dev/null; then
    echo "Installing PHP..."
    apt-get install -y php-fpm php-cli sysstat
fi

# Make sure sysstat is installed for iostat
if ! command -v iostat &> /dev/null; then
    apt-get install -y sysstat
fi

# Configure nginx to handle PHP
cat > /etc/nginx/sites-available/vpn << EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN *.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

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

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN *.$DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    root /var/www/html;
    index index.html index.htm index.php;

    # PHP handler
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
