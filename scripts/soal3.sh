#!/bin/bash
echo "===== [SOAL 3] DNS Master (Erendis) ====="
apt-get install -y bind9 bind9utils

cat > /etc/bind/named.conf.local <<EOF
zone "k08.com" {
    type master;
    file "/etc/bind/db.k08.com";
    allow-transfer { 192.215.3.102; };
};

zone "3.215.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.215.3.rev";
};
EOF

cat > /etc/bind/db.k08.com <<EOF
\$TTL 604800
@ IN SOA ns1.k08.com. root.k08.com. (
    2025110101 604800 86400 2419200 604800 )
    IN NS ns1.k08.com.
    IN NS ns2.k08.com.

ns1 IN A 192.215.3.101
ns2 IN A 192.215.3.102

palantir IN A 192.215.4.102
aldarion IN A 192.215.4.101
elendil IN A 192.215.1.101
isildur IN A 192.215.1.102
anarion IN A 192.215.1.103

@ IN A 192.215.4.102
www IN CNAME k08.com.

cincin IN TXT "Cincin Sauron"
aliansi IN TXT "Aliansi Terakhir"
EOF

cat > /etc/bind/db.192.215.3.rev <<EOF
\$TTL 604800
@ IN SOA ns1.k08.com. root.k08.com. (
    2025110101 604800 86400 2419200 604800 )
    IN NS ns1.k08.com.
101 IN PTR ns1.k08.com.
102 IN PTR ns2.k08.com.
EOF

named -g -c /etc/bind/named.conf &
echo "[+] DNS Master aktif di Erendis."
