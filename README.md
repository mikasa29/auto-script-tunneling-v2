# AUTOSCRIPT TUNNELING VPN

Script otomatis untuk setup VPN Server dengan berbagai protocol yang siap dijual/disewakan.

## 📋 Minimum Requirements

- **OS:** Ubuntu 22.04+ atau Debian 11+
- **RAM:** 1 GB (Optimized untuk low resource)
- **CPU:** 1 Core
- **Storage:** 10 GB
- **Bandwidth:** Unlimited recommended

## 🚀 Supported Protocols

- **SSH WebSocket & SSL**
- **SSH UDP Custom**
- **VMESS**
- **VLESS**
- **TROJAN**

## 📥 Installation
Jika VPS Anda belum enable SSH root login dengan password, jalankan script ini terlebih dahulu:


```bash
wget https://github.com/mikasa29/auto-script-tunneling-v2/main/system/enable-ssh-root.sh && chmod +x enable-ssh-root.sh && ./enable-ssh-root.sh
```

Script ini akan:
- ✅ Enable SSH root login
- ✅ Set password untuk root user
- ✅ Display IP, username, password untuk login
- ✅ Auto restart SSH service

**⚠️ Note:** Lewati step ini jika Anda sudah bisa login sebagai root dengan password.

---
Cara termudah, cukup jalankan perintah ini di terminal VPS Anda:
```bash
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -w net.ipv6.conf.default.disable_ipv6=1 && apt update && apt install -y bzip2 gzip coreutils screen curl wget && wget -q https://github.com/mikasa29/auto-script-tunneling-v2/main/install.sh && chmod +x install.sh && ./install.sh
```

Manual Installation (Git Clone)
Jika Anda ingin melihat source code sebelum install:
```bash
apt update && apt install git -y
git clone https://github.com/mikasa29/auto-script-tunneling-v2
cd auto-script-tunneling-v2
chmod +x setup.sh
./setup.sh
```

## ✨ Fitur Lengkap

### 📊 Management & Monitoring
- ✅ Cek Running Service
- ✅ Restart Service
- ✅ Auto Reboot (Configurable)
- ✅ Monitor VPS (CPU, RAM, Bandwidth)
- ✅ Speedtest
- ✅ Monitor Service Status

### 👤 Account Management
- ✅ Create Account
- ✅ Delete Account
- ✅ Renew Account
- ✅ Trial Account
- ✅ Lock Account
- ✅ Unlock Account
- ✅ List All Accounts
- ✅ Detail Account
- ✅ Delete All Expired Accounts

### 🔒 Security & Limits
- ✅ Limit IP per Account
- ✅ Limit Quota per Account
- ✅ Auto Lock (When limit reached)
- ✅ Auto Delete (When expired)
- ✅ Edit Limit IP & Quota
- ✅ Limit Speed VPS

### 🛠️ System Management
- ✅ Change Domain
- ✅ Change Banner/Login
- ✅ Fix Error Domain
- ✅ Fix Error Proxy
- ✅ Backup & Restore
- ✅ Auto Backup (Daily)
- ✅ Auto Record Wildcard Domain

### 🤖 Bot Telegram
- ✅ Notifikasi Telegram
- ✅ Auto Order System
- ✅ Payment QRIS (Auto & Manual)
- ✅ Notifikasi Account Expired
- ✅ Notifikasi Login User

### 🎨 Customization
- ✅ Manual UUID (XRAY)
- ✅ Semua File TIDAK DIKUNCI
- ✅ Bisa Edit Semua Config
- ✅ Custom Banner
- ✅ Custom Port

## 📦 Installation

### ⚙️ Pre-Installation (Optional - Enable SSH Root Login)



### Quick Install (One-Liner)

```bash
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -w net.ipv6.conf.default.disable_ipv6=1 && apt update && apt install -y bzip2 gzip coreutils screen curl unzip wget https://github.com/mikasa29/auto-script-tunneling-v2/main/install.sh && chmod +x install.sh && sed -i -e 's/\r$//' install.sh && screen -S setup ./install.sh
```

### Quick Install (Step by Step)

```bash
apt update && apt upgrade -y
wget -O setup.sh https://github.com/mikasa29/auto-script-tunneling-v2/main/setup.sh && chmod +x setup.sh && ./setup.sh
```

### Manual Installation

```bash
git clone https://github.com/Muzakie-ID/auto-script-tunneling-v2.git
cd auto-script-tunneling-v2
chmod +x setup.sh
./setup.sh
```

## ☁️ DNS Configuration (PENTING!)

### Cloudflare DNS Settings

Jika menggunakan Cloudflare untuk DNS management, **WAJIB nonaktifkan Cloudflare Proxy**:

#### ❌ **JANGAN GUNAKAN** (Orange Cloud 🟠)
- Cloudflare Proxy aktif
- Hanya support port 80 dan 443
- Block semua custom ports (109, 143, 442, 777, 3128, 8080)
- VPN protocols akan gagal connect

#### ✅ **GUNAKAN INI** (Gray Cloud ☁️)
- DNS Only mode
- Semua port accessible
- Direct connection ke server
- Semua protocols work properly

### Cara Setting Cloudflare:

1. Login ke [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Pilih domain Anda
3. Masuk ke menu **DNS**
4. Cari A record untuk VPN server (contoh: `vpn.yourdomain.com`)
5. Klik **Orange Cloud 🟠** → ubah jadi **Gray Cloud ☁️** (DNS Only)
6. Klik **Save**
7. Tunggu 1-5 menit untuk propagasi DNS

```
SALAH ❌:  A  vpn  123.456.789.0  🟠 Proxied
BENAR ✅:  A  vpn  123.456.789.0  ☁️ DNS Only
```

### Verifikasi DNS

Setelah setting DNS Only, verifikasi dengan:

```bash
# Cek apakah DNS sudah resolve ke IP server
nslookup vpn.yourdomain.com

# Atau menggunakan dig
dig vpn.yourdomain.com +short
```

**⚠️ CATATAN PENTING:**
- Jika tetap menggunakan Orange Cloud, hanya port 80 dan 443 yang bisa diakses
- Semua protocol selain VMESS/VLESS/TROJAN via port 443 akan gagal
- SSH, Dropbear, Stunnel, Squid tidak akan bisa diakses

## 🌐 Cloudflare API Token untuk Wildcard SSL

Jika ingin menggunakan fitur Wildcard SSL (sertifikat otomatis untuk *.domain.com), Anda harus membuat API Token Cloudflare dengan izin DNS Edit. Ikuti langkah berikut:

1. Login ke dashboard Cloudflare Anda.
2. Klik ikon profil di kanan atas, pilih **My Profile**.
3. Pilih menu **API Tokens** di kiri.
4. Klik **Create Token**.
5. Pilih template **Edit zone DNS** lalu klik **Use template**.
6. Pada **Permissions** pastikan: `Zone` - `DNS` - `Edit`
7. Pada **Zone Resources**: pilih **Include** > **Specific zone** > pilih domain Anda.
8. Klik **Continue to summary** lalu **Create Token**.
9. Salin token yang muncul (hanya muncul sekali).

Saat install, masukkan email Cloudflare dan API Token ini jika ingin mengaktifkan Wildcard SSL.

## 🔄 Update Script

### Update via Command

```bash
# Cara 1: Menggunakan update.sh
curl -sL https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling-v2/main/update.sh | bash

# Cara 2: Menggunakan git clone (Recommended)
cd /tmp && rm -rf auto-script-tunneling && git clone https://github.com/Muzakie-ID/auto-script-tunneling-v2.git && cd auto-script-tunneling && cp -f menu/*.sh ssh/*.sh system/*.sh xray/*.sh bot/*.sh /usr/local/sbin/tunneling/ && cp -f bot/telegram_bot.py /usr/local/sbin/tunneling/ && chmod +x /usr/local/sbin/tunneling/*.sh /usr/local/sbin/tunneling/telegram_bot.py && systemctl restart telegram-bot 2>/dev/null && cd ~ && rm -rf /tmp/auto-script-tunneling && echo "✓ Update completed!"

# Cara 3: Via Menu
menu → System Menu → Update/Repair Scripts
```

## 🎯 Cara Penggunaan

Setelah instalasi selesai, akses menu dengan command:

```bash
menu
```

### Menu Utama

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     AUTOSCRIPT TUNNELING VPN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. SSH Menu
2. VMESS Menu
3. VLESS Menu
4. TROJAN Menu
5. System Menu
6. Backup & Restore
7. Bot Telegram
8. Settings
9. Information
0. Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 📱 Setup Bot Telegram

1. Buat bot baru di [@BotFather](https://t.me/BotFather)
2. Copy Token Bot
3. Masuk menu: `menu` → `7. Bot Telegram` → `Setup Bot`
4. Paste Token Bot
5. Bot siap digunakan

### Fitur Bot Telegram

- `/start` - Mulai bot
- `/order` - Pesan account baru
- `/check` - Cek account
- `/renew` - Perpanjang account
- `/trial` - Minta trial account
- `/info` - Info server

## 💰 Setup Auto Order & Payment

### Setup QRIS Payment

1. Masuk menu: `menu` → `7. Bot Telegram` → `Payment Setup`
2. Upload QRIS Image
3. Set Payment Gateway (Manual/Auto)
4. Set Price List

### Cara Kerja Auto Order

1. User kirim `/order` di Telegram
2. Bot tampilkan paket & harga
3. User pilih paket
4. Bot generate QRIS payment
5. User upload bukti bayar
6. Admin approve (manual) atau Auto approve
7. Account otomatis dibuat & dikirim ke user

## 🔧 Configuration Files

Semua file konfigurasi bisa di-edit:

```
/etc/tunneling/
├── config.json          # Main config
├── ssh/                 # SSH configs
├── xray/                # XRAY configs
├── vmess/              # VMESS configs
├── vless/              # VLESS configs
├── trojan/             # TROJAN configs
├── backup/             # Backup files
└── bot/                # Bot configs
```

## 🛡️ Security Best Practices

1. **Change Default Ports** - Ubah port default setelah instalasi
2. **Enable Firewall** - UFW otomatis diaktifkan
3. **Regular Backup** - Auto backup setiap hari
4. **Update System** - Update system secara berkala
5. **Monitor Logs** - Cek log di `/var/log/tunneling/`

## 📊 Monitoring

### Cek Status Service

```bash
menu → 5. System Menu → 1. Check Services
```

### Monitor Resource

```bash
menu → 5. System Menu → 4. Monitor VPS
```

### Cek Account Login

```bash
menu → 1. SSH Menu → 6. List Online Users
```

## 🔄 Backup & Restore

### Manual Backup

```bash
menu → 6. Backup & Restore → 1. Backup Now
```

### Restore Backup

```bash
menu → 6. Backup & Restore → 2. Restore Backup
```

### Auto Backup

Auto backup otomatis jalan setiap hari pukul 02:00 WIB

## 🆘 Troubleshooting

### Fix Error Domain

```bash
menu → 8. Settings → 5. Fix Error Domain
```

### Fix Error Proxy

```bash
menu → 8. Settings → 6. Fix Error Proxy
```

### Restart All Services

```bash
menu → 5. System Menu → 2. Restart Services
```

### Check Logs

```bash
tail -f /var/log/tunneling/error.log
```

## 📝 Port Information & Firewall Configuration

### Port List untuk Inbound Rules (Cloud Provider)

Berikut adalah **daftar lengkap port** yang perlu dibuka di firewall/security group cloud provider (AWS, GCP, Azure, Vultr, dll):

#### **SSH Services (TCP)**
| Port | Service | Deskripsi |
|------|---------|-----------|
| `22` | OpenSSH | SSH standard |
| `109` | Dropbear | SSH alternative (port 1) |
| `143` | Dropbear | SSH alternative (port 2) |

#### **SSL/TLS (TCP)**
| Port | Service | Deskripsi |
|------|---------|-----------|
| `442` | Stunnel | Dropbear over SSL |
| `777` | Stunnel | OpenSSH over SSL |

#### **Proxy (TCP)**
| Port | Service | Deskripsi |
|------|---------|-----------|
| `3128` | Squid | HTTP Proxy (port 1) |
| `8080` | Squid | HTTP Proxy (port 2) |

#### **WebSocket (TCP)**
| Port | Service | Deskripsi |
|------|---------|-----------|
| `700` | WebSocket-SSH | SSH over WebSocket Bridge |

#### **Web Server / XRAY (TCP)**
| Port | Service | Deskripsi |
|------|---------|-----------|
| `80` | Nginx | HTTP (reverse proxy untuk XRAY) |
| `443` | Nginx | HTTPS/SSL (reverse proxy untuk VMESS/VLESS/TROJAN) |

#### **Internal XRAY (Localhost Only - Tidak Perlu Dibuka)**
| Port | Service | Deskripsi |
|------|---------|-----------|
| `10001` | XRAY VMESS | Internal only (127.0.0.1) |
| `10002` | XRAY VLESS | Internal only (127.0.0.1) |
| `10003` | XRAY TROJAN | Internal only (127.0.0.1) |

### Konfigurasi UFW (Ubuntu Firewall)

Script akan otomatis mengkonfigurasi UFW dengan rules berikut:

```bash
# SSH Services
ufw allow 22/tcp     # OpenSSH
ufw allow 109/tcp    # Dropbear SSH
ufw allow 143/tcp    # Dropbear SSH

# SSL/TLS
ufw allow 442/tcp    # Stunnel (Dropbear SSL)
ufw allow 777/tcp    # Stunnel (OpenSSH SSL)

# Web Server & XRAY
ufw allow 80/tcp     # HTTP (Nginx)
ufw allow 443/tcp    # HTTPS (Nginx + XRAY)
ufw allow 8443/tcp   # HTTPS Alternate

# WebSocket
ufw allow 700/tcp    # WebSocket SSH

# Proxy
ufw allow 3128/tcp   # Squid Proxy
ufw allow 8080/tcp   # Squid Proxy

# BadVPN
ufw allow 7300/tcp   # BadVPN TCP
ufw allow 7300/udp   # BadVPN UDP

# DNS
ufw allow 53/udp     # DNS

# Enable UFW
ufw --force enable
```

### Cloud Provider Inbound Rules

**Contoh untuk AWS Security Group / GCP Firewall / Azure NSG:**

| Type | Protocol | Port Range | Source | Deskripsi |
|------|----------|------------|--------|-----------|
| SSH | TCP | 22 | 0.0.0.0/0 | OpenSSH |
| HTTP | TCP | 80 | 0.0.0.0/0 | Nginx + XRAY |
| Custom TCP | TCP | 109 | 0.0.0.0/0 | Dropbear SSH |
| Custom TCP | TCP | 143 | 0.0.0.0/0 | Dropbear SSH |
| Custom TCP | TCP | 442 | 0.0.0.0/0 | Stunnel SSL (Dropbear) |
| HTTPS | TCP | 443 | 0.0.0.0/0 | Nginx + XRAY (VMESS/VLESS/TROJAN) |
| Custom TCP | TCP | 700 | 0.0.0.0/0 | WebSocket SSH |
| Custom TCP | TCP | 777 | 0.0.0.0/0 | OpenSSH SSL (Stunnel) |
| Custom TCP | TCP | 3128 | 0.0.0.0/0 | Squid Proxy |
| Custom TCP | TCP | 7300 | 0.0.0.0/0 | BadVPN UDP Gateway |
| Custom UDP | UDP | 7300 | 0.0.0.0/0 | BadVPN UDP Gateway |
| Custom TCP | TCP | 8080 | 0.0.0.0/0 | Squid Proxy |
| Custom TCP | TCP | 8443 | 0.0.0.0/0 | HTTPS Alternate |



### Arsitektur Port

```
┌─────────────────────────────────────────────────┐
│                  INTERNET                        │
└────────────────────┬────────────────────────────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
    Port 443     Port 80    Port 22-8080
         │           │           │
    ┌────▼───────────▼───────────▼────┐
    │         NGINX (Reverse Proxy)    │
    │    SSL/TLS Termination Point     │
    └────┬───────────┬───────────┬─────┘
         │           │           │
   /vmess      /vless      /trojan
         │           │           │
    ┌────▼───────────▼───────────▼────┐
    │         XRAY CORE                │
    │   127.0.0.1:10001 (VMESS)       │
    │   127.0.0.1:10002 (VLESS)       │
    │   127.0.0.1:10003 (TROJAN)      │
    └──────────────────────────────────┘
```

**⚠️ PENTING:** 
- Port **10001-10003** adalah internal port yang hanya diakses oleh Nginx
- **TIDAK PERLU** membuka port 10001-10003 di firewall
- Semua traffic XRAY di-route melalui Nginx di port 443/80

## 💡 Tips & Tricks

1. **Optimasi RAM** - Script sudah dioptimasi untuk 1GB RAM
2. **Limit User** - Set limit IP & Quota untuk kontrol bandwidth
3. **Auto Delete** - Aktifkan auto delete expired untuk hemat resource
4. **Custom Banner** - Buat banner menarik untuk branding
5. **Bot Telegram** - Otomasi penuh dengan bot telegram

## 🔄 Update Script

```bash
cd /root
wget -O update.sh https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling-v2/main/update.sh
chmod +x update.sh
./update.sh
```

## 📞 Support

- **Telegram:** @MuzakieID
- **WhatsApp:** +62
- **Email:** support@yourdomain.com

## 📄 License

Script ini TIDAK DIKUNCI dan bisa di-edit sesuai kebutuhan.
Silahkan digunakan untuk keperluan komersial (jualan/sewa VPN).

## ⚠️ Disclaimer

- Script ini untuk educational purpose
- Gunakan dengan bijak dan legal
- Admin tidak bertanggung jawab atas penyalahgunaan

## 🎉 Features Coming Soon

- [ ] Multi-user Shadowsocks
- [ ] Wireguard Support
- [ ] V2Ray Support
- [ ] Multi-domain Support
- [ ] Web Panel Admin
- [ ] Mobile App

---

**© 2024 AUTOSCRIPT TUNNELING - All Rights Reserved**

**Happy Selling! 💰**
