#!/bin/bash

# Create Clash YAML Converter Web Page
# This script creates a web-based converter for generating Clash YAML configs

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[INFO]${NC} Creating Clash YAML Converter page..."

# Create converter PHP file
cat > /var/www/html/clash-converter.php << 'EOF'
<?php
// Clash YAML Converter
$domain = trim(file_get_contents('/root/domain.txt'));

// Get VPS IP
$vps_ip = trim(shell_exec('curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null'));

// Protocols
$protocols = [
    'vmess' => 'VMESS',
    'vless' => 'VLESS', 
    'trojan' => 'TROJAN'
];

// Bug hosts examples
$bug_hosts = [
    'support.zoom.us',
    'ava.game.naver.com',
    'graph.instagram.com',
    'quiz.int.vidio.com',
    'live.iflix.com'
];

$yaml_output = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $protocol = $_POST['protocol'] ?? 'vmess';
    $bug_host = trim($_POST['bug_host'] ?? '');
    $uuid = trim($_POST['uuid'] ?? '');
    $password = trim($_POST['password'] ?? '');
    $name = trim($_POST['name'] ?? 'VPN-Config');
    
    // Build full SNI
    $sni = $bug_host ? "$bug_host.$domain" : $domain;
    
    // Validate
    if (empty($uuid) && $protocol !== 'trojan') {
        $error = "UUID is required for $protocol";
    } elseif (empty($password) && $protocol === 'trojan') {
        $error = "Password is required for TROJAN";
    } else {
        // Generate YAML based on protocol
        switch ($protocol) {
            case 'vmess':
                $yaml_output = "- name: $name-vmess
  server: $sni
  port: 443
  type: vmess
  uuid: $uuid
  alterId: 0
  cipher: auto
  tls: true
  skip-cert-verify: false
  servername: $sni
  network: ws
  ws-opts:
    path: /vmess
    headers:
      Host: $sni
  udp: true";
                break;
                
            case 'vless':
                $yaml_output = "- name: $name-vless
  server: $sni
  port: 443
  type: vless
  uuid: $uuid
  tls: true
  skip-cert-verify: false
  servername: $sni
  network: ws
  ws-path: /vless
  ws-headers:
    Host: $sni
  udp: true";
                break;
                
            case 'trojan':
                $yaml_output = "- name: $name-trojan
  server: $sni
  port: 443
  type: trojan
  password: $password
  skip-cert-verify: false
  sni: $sni
  network: ws
  ws-opts:
    path: /trojan
    headers:
      Host: $sni
  udp: true";
                break;
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Clash YAML Converter - <?= $domain ?></title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        .header p {
            opacity: 0.9;
            font-size: 14px;
        }
        
        .content {
            padding: 30px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: #333;
        }
        
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .form-group small {
            display: block;
            margin-top: 5px;
            color: #666;
            font-size: 12px;
        }
        
        .btn {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
        }
        
        .btn:hover {
            transform: translateY(-2px);
        }
        
        .btn:active {
            transform: translateY(0);
        }
        
        .output-box {
            margin-top: 30px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 8px;
            border-left: 4px solid #667eea;
        }
        
        .output-box h3 {
            margin-bottom: 15px;
            color: #333;
        }
        
        .yaml-output {
            background: #2d3748;
            color: #68d391;
            padding: 20px;
            border-radius: 8px;
            font-family: 'Courier New', monospace;
            font-size: 13px;
            line-height: 1.6;
            white-space: pre-wrap;
            word-wrap: break-word;
            overflow-x: auto;
            position: relative;
        }
        
        .copy-btn {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 8px 15px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 12px;
        }
        
        .copy-btn:hover {
            background: #5568d3;
        }
        
        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .alert-error {
            background: #fee;
            border-left: 4px solid #f44;
            color: #c33;
        }
        
        .alert-success {
            background: #efe;
            border-left: 4px solid #4c4;
            color: #3a3;
        }
        
        .back-link {
            display: inline-block;
            margin-top: 20px;
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }
        
        .back-link:hover {
            text-decoration: underline;
        }
        
        .info-box {
            background: #e3f2fd;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #2196f3;
        }
        
        .info-box strong {
            color: #1976d2;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔄 Clash YAML Converter</h1>
            <p>Generate Clash configuration from your VPN credentials</p>
        </div>
        
        <div class="content">
            <div class="info-box">
                <strong>📍 Server:</strong> <?= $domain ?> (<?= $vps_ip ?>)
            </div>
            
            <?php if ($error): ?>
                <div class="alert alert-error">
                    ❌ <?= htmlspecialchars($error) ?>
                </div>
            <?php endif; ?>
            
            <form method="POST">
                <div class="form-group">
                    <label for="protocol">Protocol</label>
                    <select name="protocol" id="protocol" required onchange="toggleFields()">
                        <option value="vmess" <?= ($_POST['protocol'] ?? '') === 'vmess' ? 'selected' : '' ?>>VMESS</option>
                        <option value="vless" <?= ($_POST['protocol'] ?? '') === 'vless' ? 'selected' : '' ?>>VLESS</option>
                        <option value="trojan" <?= ($_POST['protocol'] ?? '') === 'trojan' ? 'selected' : '' ?>>TROJAN</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="name">Config Name</label>
                    <input type="text" name="name" id="name" value="<?= htmlspecialchars($_POST['name'] ?? 'VPN-Config') ?>" required>
                    <small>Display name for this configuration</small>
                </div>
                
                <div class="form-group">
                    <label for="bug_host">Bug Host (Optional)</label>
                    <select name="bug_host" id="bug_host">
                        <option value="">-- None (Direct to <?= $domain ?>) --</option>
                        <?php foreach ($bug_hosts as $host): ?>
                            <option value="<?= $host ?>" <?= ($_POST['bug_host'] ?? '') === $host ? 'selected' : '' ?>><?= $host ?></option>
                        <?php endforeach; ?>
                    </select>
                    <small>Optional: Use bug host for SNI routing</small>
                </div>
                
                <div class="form-group" id="uuid-field">
                    <label for="uuid">UUID</label>
                    <input type="text" name="uuid" id="uuid" value="<?= htmlspecialchars($_POST['uuid'] ?? '') ?>" placeholder="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx">
                    <small>User UUID from VMESS/VLESS account</small>
                </div>
                
                <div class="form-group" id="password-field" style="display: none;">
                    <label for="password">Password</label>
                    <input type="text" name="password" id="password" value="<?= htmlspecialchars($_POST['password'] ?? '') ?>" placeholder="trojan-password">
                    <small>User password from TROJAN account</small>
                </div>
                
                <button type="submit" class="btn">🚀 Generate YAML</button>
            </form>
            
            <?php if ($yaml_output): ?>
                <div class="output-box">
                    <h3>✅ Generated Clash YAML Configuration</h3>
                    <div class="yaml-output" id="yamlOutput">
<button class="copy-btn" onclick="copyYAML()">📋 Copy</button><?= htmlspecialchars($yaml_output) ?></div>
                    <small style="color: #666; margin-top: 10px; display: block;">
                        💡 Copy this configuration and paste it into your Clash proxies section
                    </small>
                </div>
            <?php endif; ?>
            
            <a href="/" class="back-link">← Back to Dashboard</a>
        </div>
    </div>
    
    <script>
        function toggleFields() {
            const protocol = document.getElementById('protocol').value;
            const uuidField = document.getElementById('uuid-field');
            const passwordField = document.getElementById('password-field');
            
            if (protocol === 'trojan') {
                uuidField.style.display = 'none';
                passwordField.style.display = 'block';
                document.getElementById('uuid').required = false;
                document.getElementById('password').required = true;
            } else {
                uuidField.style.display = 'block';
                passwordField.style.display = 'none';
                document.getElementById('uuid').required = true;
                document.getElementById('password').required = false;
            }
        }
        
        function copyYAML() {
            const yamlText = document.getElementById('yamlOutput').innerText.replace('📋 Copy', '').trim();
            navigator.clipboard.writeText(yamlText).then(() => {
                const btn = document.querySelector('.copy-btn');
                btn.textContent = '✅ Copied!';
                setTimeout(() => {
                    btn.textContent = '📋 Copy';
                }, 2000);
            });
        }
        
        // Initialize on page load
        toggleFields();
    </script>
</body>
</html>
EOF

echo -e "${GREEN}[✓]${NC} Clash converter page created at /var/www/html/clash-converter.php"

# Set permissions
chown www-data:www-data /var/www/html/clash-converter.php
chmod 644 /var/www/html/clash-converter.php

echo -e "${CYAN}[INFO]${NC} Access the converter at: https://$(cat /root/domain.txt)/clash-converter.php"
echo ""
