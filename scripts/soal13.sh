#!/bin/bash
# ==============================================
# SOAL NOMOR 13 - Nginx per Taman Peri
# Node: Galadriel / Celeborn / Oropher
# ==============================================

echo "=============================="
echo "[1] Deteksi hostname dan set port"
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
    echo "❌ Hostname tidak dikenali. Pastikan node bernama galadriel / celeborn / oropher."
    exit 1
    ;;
esac

echo "Hostname terdeteksi: $HOSTNAME"
echo "Port akan digunakan: $PORT"

echo "=============================="
echo "[2] Pastikan Nginx dan PHP-FPM sudah terpasang"
echo "=============================="
apt update -y
apt install -y nginx php8.4-fpm

echo "=============================="
echo "[3] Membuat web root dan file index.php"
echo "=============================="
mkdir -p /var/www/html
cat > /var/www/html/index.php <<EOF
<?php
echo "<h2>Halo, ini taman digital milik $HOSTNAME 🌿</h2>";
echo "<p>Server berjalan di port $PORT</p>";
echo "<p>Hostname: " . gethostname() . "</p>";
?>
EOF
chmod -R 755 /var/www/html

echo "=============================="
echo "[4] Mengonfigurasi Nginx untuk mendengarkan port $PORT"
echo "=============================="
cat > /etc/nginx/sites-available/peri-$HOSTNAME.conf <<EOF
server {
    listen $PORT;
    server_name $HOSTNAME.k08.com;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    # Blok akses via IP langsung
    if (\$host ~* ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$) {
        return 403;
    }
}
EOF

echo "=============================="
echo "[5] Aktifkan konfigurasi Nginx dan restart service"
echo "=============================="
ln -sf /etc/nginx/sites-available/peri-$HOSTNAME.conf /etc/nginx/sites-enabled/peri-$HOSTNAME.conf
rm -f /etc/nginx/sites-enabled/default

service php8.4-fpm start
service nginx start
service php8.4-fpm restart
service nginx restart

echo "=============================="
echo "[✅] Konfigurasi selesai!"
echo "Node: $HOSTNAME"
echo "Port: $PORT"
echo "Akses: http://$HOSTNAME.k08.com:$PORT"
echo "=============================="
