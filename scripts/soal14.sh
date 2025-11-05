#!/bin/bash
# ==============================================
# SOAL NOMOR 14 - Basic Auth pada Worker PHP
# Node: Galadriel / Celeborn / Oropher
# ==============================================

echo "=============================="
echo "[1] Deteksi hostname"
echo "=============================="

HOSTNAME=$(hostname)
PORT=""

case "$HOSTNAME" in
  Galadriel)
    PORT=8004
    ;;
  Celeborn)
    PORT=8005
    ;;
  Oropher)
    PORT=8006
    ;;
  *)
    echo "❌ Hostname tidak dikenali. Jalankan di galadriel / celeborn / oropher."
    exit 1
    ;;
esac

echo "Hostname terdeteksi: $HOSTNAME"
echo "Port: $PORT"

echo "=============================="
echo "[2] Pastikan Nginx dan utilitas auth tersedia"
echo "=============================="
apt update -y
apt install -y apache2-utils nginx php8.4-fpm

echo "=============================="
echo "[3] Membuat file password untuk Basic Auth"
echo "=============================="
# Simpan password di /etc/nginx/.htpasswd
htpasswd -bc /etc/nginx/.htpasswd noldor silvan

echo "=============================="
echo "[4] Tambahkan konfigurasi Basic Auth di Nginx"
echo "=============================="
cat > /etc/nginx/sites-available/peri-$HOSTNAME.conf <<EOF
server {
    listen $PORT;
    server_name $HOSTNAME.k08.com;

    root /var/www/html;
    index index.php index.html;

    # Proteksi Basic Auth
    auth_basic "Restricted Area";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    # Blok akses langsung via IP
    if (\$host ~* ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$) {
        return 403;
    }
}
EOF

echo "=============================="
echo "[5] Aktifkan konfigurasi dan restart service"
echo "=============================="
ln -sf /etc/nginx/sites-available/peri-$HOSTNAME.conf /etc/nginx/sites-enabled/peri-$HOSTNAME.conf
rm -f /etc/nginx/sites-enabled/default

service php8.4-fpm start
service nginx start
service php8.4-fpm restart
service nginx restart

echo "=============================="
echo "[✅] Basic Auth diterapkan!"
echo "Node: $HOSTNAME"
echo "Port: $PORT"
echo "Username: noldor"
echo "Password: silvan"
echo "Akses: http://$HOSTNAME.k08.com:$PORT"
echo "=============================="
