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
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-dark: #1B211A;
            --green-primary: #628141;
            --green-light: #8BAE66;
            --beige: #EBD5AB;
            --glass: rgba(255, 255, 255, 0.03);
            --border: rgba(139, 174, 102, 0.2);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--bg-dark);
            color: var(--beige);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            background-image: 
                radial-gradient(circle at 10% 20%, rgba(98, 129, 65, 0.1) 0%, transparent 20%),
                radial-gradient(circle at 90% 80%, rgba(139, 174, 102, 0.1) 0%, transparent 20%);
        }
        .container {
            width: 100%;
            max-width: 1000px;
            display: grid;
            grid-template-columns: 1fr;
            gap: 2rem;
        }
        .header {
            text-align: center;
            margin-bottom: 1rem;
        }
        h1 {
            font-size: 3rem;
            font-weight: 700;
            background: linear-gradient(to right, var(--beige), var(--green-light));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 0.5rem;
            letter-spacing: -1px;
        }
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(98, 129, 65, 0.2);
            color: var(--green-light);
            border: 1px solid var(--green-primary);
            padding: 6px 16px;
            border-radius: 100px;
            font-size: 0.9rem;
            font-weight: 600;
        }
        .status-dot {
            width: 8px;
            height: 8px;
            background-color: #4ade80;
            border-radius: 50%;
            box-shadow: 0 0 10px #4ade80;
        }

        .grid-dashboard {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
        }

        /* Cards */
        .card {
            background: var(--glass);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 25px;
            backdrop-filter: blur(10px);
            transition: transform 0.3s ease, border-color 0.3s ease;
        }
        .card:hover {
            transform: translateY(-5px);
            border-color: var(--green-primary);
        }

        .metric-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
        }
        .metric-item {
            background: rgba(0,0,0,0.2);
            padding: 15px;
            border-radius: 15px;
            text-align: center;
        }
        .metric-label {
            font-size: 0.8rem;
            color: var(--green-light);
            margin-bottom: 5px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .metric-value {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--beige);
        }
        .metric-unit {
            font-size: 0.8rem;
            color: rgba(235, 213, 171, 0.5);
        }

        /* Chart */
        .chart-container {
            height: 300px;
            width: 100%;
        }

        /* Server Info */
        .info-list {
            list-style: none;
        }
        .info-list li {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid var(--border);
            color: rgba(235, 213, 171, 0.8);
        }
        .info-list li:last-child {
            border-bottom: none;
        }
        .info-list span.value {
            color: var(--green-light);
            font-weight: 600;
        }

        /* CTA Button */
        .cta-container {
            text-align: center;
            margin-top: 1rem;
        }
        .telegram-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: var(--green-primary);
            color: var(--bg-dark);
            padding: 16px 40px;
            border-radius: 12px;
            font-weight: 700;
            text-decoration: none;
            font-size: 1.1rem;
            transition: all 0.3s ease;
            box-shadow: 0 4px 20px rgba(98, 129, 65, 0.3);
        }
        .telegram-btn:hover {
            background: var(--green-light);
            transform: scale(1.02);
            box-shadow: 0 6px 25px rgba(139, 174, 102, 0.4);
        }

        .footer {
            text-align: center;
            margin-top: 3rem;
            color: rgba(139, 174, 102, 0.5);
            font-size: 0.8rem;
        }
    </style>
</head>
<body>
    <div class="container">
        
        <!-- Header -->
        <div class="header">
            <div class="status-badge"><div class="status-dot"></div> SYSTEM OPERATIONAL</div>
            <h1 style="margin-top: 15px;">VPN SERVER</h1>
            <p style="color: var(--green-light);">$DOMAIN</p>
        </div>

        <div class="grid-dashboard">
            
            <!-- Metrics Column -->
            <div class="card">
                <h3 style="margin-bottom: 20px; color: var(--green-light);">SYSTEM METRICS</h3>
                <div class="metric-grid">
                    <div class="metric-item">
                        <div class="metric-label">CPU LOAD</div>
                        <div class="metric-value"><span id="cpu">0</span><span class="metric-unit">%</span></div>
                    </div>
                    <div class="metric-item">
                        <div class="metric-label">RAM USAGE</div>
                        <div class="metric-value"><span id="ram">0</span><span class="metric-unit">MB</span></div>
                    </div>
                    <div class="metric-item">
                        <div class="metric-label">DISK I/O</div>
                        <div class="metric-value"><span id="disk">0</span><span class="metric-unit">MB/s</span></div>
                    </div>
                    <div class="metric-item">
                        <div class="metric-label">NETWORK</div>
                        <div class="metric-value"><span id="network">0</span><span class="metric-unit">Mbps</span></div>
                    </div>
                </div>
            </div>

            <!-- Server Info Column -->
            <div class="card">
                <h3 style="margin-bottom: 20px; color: var(--green-light);">SERVER DETAILS</h3>
                <ul class="info-list">
                    <li><span>Domain</span> <span class="value">$DOMAIN</span></li>
                    <li><span>Location</span> <span class="value">Singapore (SG)</span></li>
                    <li><span>ISP</span> <span class="value">DigitalOcean</span></li>
                    <li><span>Protocols</span> <span class="value">VMESS, VLESS, TROJAN, SSH</span></li>
                </ul>
                <div class="cta-container" style="margin-top: 25px;">
                    <a href="https://t.me/yourvpnbot" class="telegram-btn">
                        <span>⚡ ORDER VIA BOT</span>
                    </a>
                </div>
            </div>

        </div>

        <!-- Chart Section -->
        <div class="card">
            <h3 style="margin-bottom: 20px; color: var(--green-light);">TRAFFIC ANALYTICS</h3>
            <div class="chart-container">
                <canvas id="metricsChart"></canvas>
            </div>
        </div>

        <div class="footer">
            <p>&copy; 2026 MUZAKIE TUNNELING. SECURED BY XRAY.</p>
        </div>
    </div>

    <script>
        // Colors & Config based on new palette
        const colors = {
            primary: '#628141',
            light: '#8BAE66',
            beige: '#EBD5AB',
            grid: 'rgba(139, 174, 102, 0.1)'
        };

        const ctx = document.getElementById('metricsChart');
        const maxDataPoints = 20;
        
        // Init Chart with Modern Config
        Chart.defaults.color = colors.light;
        Chart.defaults.borderColor = colors.grid;
        
        const chartData = {
            labels: [],
            datasets: [
                {
                    label: 'CPU',
                    data: [],
                    borderColor: colors.beige,
                    backgroundColor: 'rgba(235, 213, 171, 0.1)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 0
                },
                {
                    label: 'RAM',
                    data: [],
                    borderColor: colors.primary,
                    backgroundColor: 'rgba(98, 129, 65, 0.1)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 0
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
                        labels: {
                            font: { family: 'Outfit' },
                            usePointStyle: true,
                            boxWidth: 8
                        }
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false,
                        backgroundColor: '#1B211A',
                        titleColor: '#EBD5AB',
                        bodyColor: '#8BAE66',
                        borderColor: '#628141',
                        borderWidth: 1
                    }
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { display: false }
                    },
                    y: {
                        beginAtZero: true,
                        max: 100,
                        grid: { color: colors.grid }
                    }
                },
                interaction: {
                    mode: 'nearest',
                    axis: 'x',
                    intersect: false
                }
            }
        });

        // Update Logic
        async function updateMetrics() {
            try {
                const response = await fetch('/metrics.php');
                const data = await response.json();
                
                // DOM Update
                document.getElementById('cpu').textContent = data.cpu.toFixed(1);
                document.getElementById('ram').textContent = data.ram_used.toFixed(0);
                document.getElementById('disk').textContent = data.disk_io.toFixed(2);
                document.getElementById('network').textContent = data.network.toFixed(1);
                
                // Chart Update
                const now = new Date().toLocaleTimeString();
                chartData.labels.push(now);
                chartData.datasets[0].data.push(data.cpu);
                chartData.datasets[1].data.push(data.ram_percent);
                
                if (chartData.labels.length > maxDataPoints) {
                    chartData.labels.shift();
                    chartData.datasets.forEach(dataset => dataset.data.shift());
                }
                
                chart.update('none');
            } catch (error) {
                console.error('Metrics Error:', error);
            }
        }

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
    $stat1 = file('/proc/stat');
    sleep(1);
    $stat2 = file('/proc/stat');
    
    $info1 = explode(" ", preg_replace("!cpu +!", "", $stat1[0]));
    $info2 = explode(" ", preg_replace("!cpu +!", "", $stat2[0]));
    
    $dif = array();
    $dif['user'] = $info2[0] - $info1[0];
    $dif['nice'] = $info2[1] - $info1[1];
    $dif['sys'] = $info2[2] - $info1[2];
    $dif['idle'] = $info2[3] - $info1[3];
    $total = array_sum($dif);
    $cpu = 100 - ($dif['idle'] * 100 / $total);
    
    return round($cpu, 2);
}

// Get RAM usage
function getRamUsage() {
    $free = shell_exec('free -m');
    $free = (string)trim($free);
    $free_arr = explode("\n", $free);
    $mem = explode(" ", $free_arr[1]);
    $mem = array_filter($mem);
    $mem = array_merge($mem);
    
    return array(
        'total' => (float)$mem[1],
        'used' => (float)$mem[2],
        'free' => (float)$mem[3],
        'percent' => round(($mem[2] / $mem[1]) * 100, 2)
    );
}

// Get Disk I/O
function getDiskIO() {
    $output = shell_exec("iostat -d -m 1 2 | tail -n 2 | head -n 1 | awk '{print \$3+\$4}'");
    return round((float)trim($output), 2);
}

// Get Network bandwidth
function getNetworkBandwidth() {
    $interface = trim(shell_exec("ip route | grep default | awk '{print \$5}' | head -n1"));
    if (empty($interface)) {
        return 0;
    }
    
    $rx1 = (float)file_get_contents("/sys/class/net/$interface/statistics/rx_bytes");
    $tx1 = (float)file_get_contents("/sys/class/net/$interface/statistics/tx_bytes");
    sleep(1);
    $rx2 = (float)file_get_contents("/sys/class/net/$interface/statistics/rx_bytes");
    $tx2 = (float)file_get_contents("/sys/class/net/$interface/statistics/tx_bytes");
    
    $rx = ($rx2 - $rx1) * 8 / 1000000; // Convert to Mbit/s
    $tx = ($tx2 - $tx1) * 8 / 1000000;
    
    return round($rx + $tx, 2);
}

$ram = getRamUsage();

$metrics = array(
    'cpu' => getCpuUsage(),
    'ram_total' => $ram['total'],
    'ram_used' => $ram['used'],
    'ram_free' => $ram['free'],
    'ram_percent' => $ram['percent'],
    'disk_io' => getDiskIO(),
    'network' => getNetworkBandwidth(),
    'timestamp' => time()
);

echo json_encode($metrics);
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
