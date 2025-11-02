#!/bin/bash
echo "===== [SOAL 4] DNS Slave (Amdir) ====="
apt-get install -y bind9 bind9utils

cat > /etc/bind/named.conf.local <<EOF
zone "k08.com" {
    type slave;
    masters { 192.215.3.101; };
    file "/var/lib/bind/db.k08.com";
};

zone "3.215.192.in-addr.arpa" {
    type slave;
    masters { 192.215.3.101; };
    file "/var/lib/bind/db.192.215.3.rev";
};
EOF

named -g -c /etc/bind/named.conf &
echo "[+] DNS Slave aktif di Amdir."
