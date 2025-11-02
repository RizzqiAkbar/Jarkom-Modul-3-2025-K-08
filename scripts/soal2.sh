#!/bin/bash
echo "===== [SOAL 2] DHCP Server (Aldarion) ====="
apt-get install -y isc-dhcp-server

cat > /etc/default/isc-dhcp-server <<EOF
INTERFACESv4="eth0"
EOF

cat > /etc/dhcp/dhcpd.conf <<EOF
subnet 192.215.4.0 netmask 255.255.255.0 {
    range 192.215.4.10 192.215.4.50;
    option routers 192.215.4.1;
    option broadcast-address 192.215.4.255;
    option domain-name-servers 192.215.3.101;
    default-lease-time 600;
    max-lease-time 7200;
}

host khamul {
    hardware ethernet 02:42:c0:d7:04:aa;
    fixed-address 192.215.4.99;
}
EOF

pkill dhcpd 2>/dev/null
dhcpd -4 -cf /etc/dhcp/dhcpd.conf eth0
echo "[+] DHCP aktif di Aldarion."
