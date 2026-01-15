#!/bin/bash

# Quick fix metrics.php with proper disk & network monitoring

cat > /var/www/html/metrics.php << 'EOF'
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Get CPU usage
function getCpuUsage() {
    exec("grep 'cpu ' /proc/stat", $output);
    if (empty($output)) return 0;
    
    preg_match_all('/\d+/', $output[0], $matches);
    $cpu = $matches[0];
    $total = array_sum($cpu);
    $idle = $cpu[3];
    
    return $total > 0 ? round((($total - $idle) / $total) * 100, 2) : 0;
}

// Get RAM usage
function getRamUsage() {
    $free = shell_exec('free -m');
    if (empty($free)) return array('total' => 0, 'used' => 0, 'percent' => 0);
    
    preg_match_all('/Mem:\s+(\d+)\s+(\d+)/', $free, $matches);
    if (empty($matches[1])) return array('total' => 0, 'used' => 0, 'percent' => 0);
    
    $total = (float)$matches[1][0];
    $used = (float)$matches[2][0];
    
    return array(
        'total' => $total,
        'used' => $used,
        'percent' => $total > 0 ? round(($used / $total) * 100, 2) : 0
    );
}

// Get Disk I/O
function getDiskIO() {
    $output = shell_exec("iostat -d -m 1 2 2>/dev/null | tail -n 2 | head -n 1");
    if (empty($output)) return 0;
    
    preg_match_all('/[\d.]+/', $output, $matches);
    if (isset($matches[0][2]) && isset($matches[0][3])) {
        return round((float)$matches[0][2] + (float)$matches[0][3], 2);
    }
    return 0;
}

// Get Network bandwidth
function getNetworkBandwidth() {
    $interface = trim(shell_exec("ip route 2>/dev/null | grep default | awk '{print \$5}' | head -n1"));
    if (empty($interface)) return 0;
    
    $rx_file = "/sys/class/net/$interface/statistics/rx_bytes";
    $tx_file = "/sys/class/net/$interface/statistics/tx_bytes";
    
    if (!file_exists($rx_file) || !file_exists($tx_file)) return 0;
    
    $rx1 = (float)file_get_contents($rx_file);
    $tx1 = (float)file_get_contents($tx_file);
    
    sleep(1);
    
    $rx2 = (float)file_get_contents($rx_file);
    $tx2 = (float)file_get_contents($tx_file);
    
    $rx = ($rx2 - $rx1) * 8 / 1000000; // to Mbit/s
    $tx = ($tx2 - $tx1) * 8 / 1000000;
    
    return round($rx + $tx, 2);
}

$ram = getRamUsage();

$metrics = array(
    'cpu' => getCpuUsage(),
    'ram_total' => $ram['total'],
    'ram_used' => $ram['used'],
    'ram_percent' => $ram['percent'],
    'disk_io' => getDiskIO(),
    'network' => getNetworkBandwidth(),
    'timestamp' => time()
);

echo json_encode($metrics);
?>
EOF

echo "✓ metrics.php updated with proper monitoring"

# Install sysstat if not present
if ! command -v iostat &> /dev/null; then
    echo "Installing sysstat..."
    apt-get update -qq
    apt-get install -y sysstat
    echo "✓ sysstat installed"
fi

# Test
echo ""
echo "Testing metrics..."
php /var/www/html/metrics.php
