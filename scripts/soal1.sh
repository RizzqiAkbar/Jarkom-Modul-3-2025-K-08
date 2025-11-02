#!/bin/bash
echo "===== [SOAL 1] Konfigurasi Dasar IP & Repository ====="

apt-get update -y
apt-get install -y net-tools iproute2 dnsutils curl wget nano unzip git lynx

# Contoh konfigurasi IP untuk masing-masing node (ubah sesuai node)
# Simpan di: /etc/network/interfaces
cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
    address 192.215.1.101
    netmask 255.255.255.0
    gateway 192.215.1.1
    up echo nameserver 192.215.3.101 > /etc/resolv.conf
EOF

echo "[+] IP configuration applied."
