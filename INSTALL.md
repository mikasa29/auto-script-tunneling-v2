# 🚀 CARA INSTALASI AUTOSCRIPT TUNNELING VPN

Panduan lengkap instalasi VPN Server untuk Ubuntu 22.04+ dan Debian 11+

## 📋 Persiapan

### 1. VPS Requirements
- OS: Ubuntu 22.04+ atau Debian 11+
- RAM: Minimal 1GB
- CPU: Minimal 1 Core
- Storage: Minimal 10GB
- Root Access

### 2. Domain
Siapkan domain yang sudah diarahkan ke IP VPS Anda:
- Domain utama atau subdomain
- Pastikan DNS sudah propagate (cek dengan `ping namadomain.com`)

### 3. Port yang Digunakan
Pastikan port berikut tidak diblokir oleh firewall provider:
- 22, 80, 443 (Wajib)
- 109, 143, 442 (SSH)
- 3128, 8080 (Proxy)
- 2082, 2086, 2087, 2095, 2096

## 🔧 Instalasi

### Method 1: Quick Install (Recommended)

```bash
# Login sebagai root
su root

# Update system
apt update && apt upgrade -y

# Install script
wget https://github.com/mikasa29/auto-script-tunneling-v2/main/setup.sh && chmod +x setup.sh && ./setup.sh
```

### Method 2: Manual Install

```bash
# Clone repository
git clone https://github.com/mikasa29/auto-script-tunneling-v2.git
cd auto-script-tunneling-v2

# Jalankan installer
chmod +x setup.sh
./setup.sh
```

## 📝 Proses Instalasi

1. **Input Domain**
   ```
   Enter your domain: vpn.yourdomain.com
   ```

2. **Input Email (untuk SSL)**
   ```
   Enter your email for SSL certificate: admin@yourdomain.com
   ```

3. **Tunggu Proses Instalasi**
   - Update & upgrade system
   - Install dependencies
   - Install & konfigurasi SSH, Dropbear, Stunnel
   - Install & konfigurasi XRAY
   - Install & konfigurasi Nginx
   - Setup SSL Certificate (Let's Encrypt)
   - Setup Firewall
   - Konfigurasi auto backup & auto reboot

4. **Instalasi Selesai**
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
             INSTALLATION COMPLETED SUCCESSFULLY!
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Domain       : vpn.yourdomain.com
   IP Address   : 123.456.789.0
   Install Date : 2024-01-01
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Type 'menu' to access the control panel
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

## 🎯 Akses Menu

Setelah instalasi selesai, akses menu dengan:

```bash
menu
```

## ⚙️ Konfigurasi Awal

### 1. Setup Bot Telegram (Opsional tapi Recommended)

```bash
menu → 7. Bot Telegram → 1. Setup Bot Telegram
```

**Langkah-langkah:**
1. Buka [@BotFather](https://t.me/BotFather) di Telegram
2. Kirim `/newbot`
3. Ikuti instruksi untuk buat bot baru
4. Copy bot token
5. Paste di menu setup
6. Masukkan User ID Telegram Anda (cari di [@userinfobot](https://t.me/userinfobot))

### 2. Upload QRIS untuk Payment (Jika pakai bot)

```bash
menu → 7. Bot Telegram → 7. Payment Settings
```

Upload gambar QRIS Anda untuk terima pembayaran otomatis.

### 3. Set Price List

```bash
menu → 7. Bot Telegram → 8. Price List Settings
```

Atur harga untuk setiap paket yang akan dijual.

### 4. Custom Banner (Opsional)

```bash
menu → 8. Settings → 2. Change Banner
```

Buat banner custom untuk branding VPN Anda.

## 📱 Setup Bot Auto Order

### 1. Konfigurasi Bot

File config bot ada di: `/etc/tunneling/bot/config.json`

```json
{
    "token": "YOUR_BOT_TOKEN",
    "admin_id": "YOUR_TELEGRAM_ID",
    "auto_approve": false,
    "trial_enabled": true
}
```

### 2. Start Bot

```bash
menu → 7. Bot Telegram → 2. Start Bot
```

atau via command:
```bash
systemctl start telegram-bot
systemctl enable telegram-bot
```

### 3. Test Bot

Buka bot Anda di Telegram dan kirim `/start`

## 🔐 Membuat Account SSH Pertama

### Via Menu:

```bash
menu → 1. SSH Menu → 1. Create SSH Account
```

Input:
- Username: test01
- Password: password123
- Expired (days): 30
- Limit IP: 2
- Limit Quota GB: 50

### Via Command Line:

```bash
cd /usr/local/sbin/tunneling
./ssh-create.sh
```

## 🌐 Membuat Account VMESS/VLESS/TROJAN

Sama seperti SSH, pilih menu sesuai protocol yang diinginkan:

```bash
menu → 2. VMESS Menu → 1. Create VMESS Account
menu → 3. VLESS Menu → 1. Create VLESS Account
menu → 4. TROJAN Menu → 1. Create TROJAN Account
```

## 📊 Monitoring

### Check Services

```bash
menu → 5. System Menu → 1. Check Running Services
```

### Monitor VPS

```bash
menu → 5. System Menu → 4. Monitor VPS
```

### Speedtest

```bash
menu → 5. System Menu → 5. Speedtest
```

## 🔄 Backup & Restore

### Manual Backup

```bash
menu → 6. Backup & Restore → 1. Backup Now
```

Backup akan tersimpan di: `/etc/tunneling/backup/`

### Auto Backup

Auto backup otomatis jalan setiap hari jam 02:00 WIB.

Untuk ubah jadwal, edit cron:
```bash
crontab -e
```

### Restore Backup

```bash
menu → 6. Backup & Restore → 2. Restore Backup
```

## 🛠️ Troubleshooting

### Error: Domain not working

```bash
menu → 8. Settings → 5. Fix Error Domain
```

### Error: Proxy not working

```bash
menu → 8. Settings → 6. Fix Error Proxy
```

### SSL Certificate Error

```bash
menu → 8. Settings → 7. Renew SSL Certificate
```

### Service not running

```bash
# Restart semua service
menu → 5. System Menu → 2. Restart All Services

# Atau restart specific service
systemctl restart xray
systemctl restart nginx
systemctl restart ssh
```

### Check Logs

```bash
# XRAY logs
tail -f /var/log/xray/error.log

# Nginx logs
tail -f /var/log/nginx/error.log

# System logs
tail -f /var/log/tunneling/error.log
```

## 🔒 Security Tips

1. **Ganti Password Root**
   ```bash
   passwd
   ```

2. **Disable Password Login (Pakai SSH Key)**
   ```bash
   nano /etc/ssh/sshd_config
   # Set: PasswordAuthentication no
   systemctl restart ssh
   ```

3. **Enable Fail2Ban**
   ```bash
   systemctl enable fail2ban
   systemctl start fail2ban
   ```

4. **Regular Update**
   ```bash
   apt update && apt upgrade -y
   ```

5. **Monitor Logs**
   Cek logs secara berkala untuk deteksi aktivitas mencurigakan.

## 🎯 Tips Jualan VPN

1. **Set Limit IP & Quota**
   - Limit IP: Cegah sharing account
   - Limit Quota: Kontrol bandwidth usage

2. **Aktifkan Auto Delete Expired**
   ```bash
   # Sudah otomatis via cron
   # Cek: crontab -l
   ```

3. **Gunakan Bot Telegram**
   - Otomasi order
   - Payment tracking
   - Notifikasi realtime

4. **Custom Banner**
   - Branding VPN Anda
   - Info kontak & support

5. **Regular Backup**
   - Backup sebelum maintenance
   - Simpan backup di tempat aman

## 📞 Support

Jika ada masalah saat instalasi:

1. Cek log error: `/var/log/tunneling/error.log`
2. Cek service status: `menu → 5 → 1`
3. Restart services: `menu → 5 → 2`

## 🔄 Update Script

```bash
cd /root
wget https://github.com/mikasa29/auto-script-tunneling-v2/main/update.sh
chmod +x update.sh
./update.sh
```

## ❗ Important Notes

1. Script ini **TIDAK DIKUNCI** - Semua file bisa diedit
2. Backup data secara berkala
3. Gunakan untuk tujuan legal dan ethical
4. Recommended: Gunakan CloudFlare untuk CDN & protection

## ✅ Checklist Setelah Instalasi

- [ ] Domain sudah terkoneksi dengan SSL
- [ ] Semua service running
- [ ] Bot Telegram sudah setup (jika pakai)
- [ ] QRIS payment sudah upload (jika pakai)
- [ ] Price list sudah diatur
- [ ] Test create account
- [ ] Test koneksi SSH/VMESS/VLESS/TROJAN
- [ ] Backup pertama sudah dibuat
- [ ] Custom banner (opsional)

## 🎉 Selamat!

VPN Server Anda sudah siap untuk dijual/disewakan!

**Happy Selling! 💰**

---

© 2024 AUTOSCRIPT TUNNELING - All Rights Reserved
