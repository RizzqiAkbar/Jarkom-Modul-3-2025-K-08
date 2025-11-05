#!/bin/bash
echo "=============================="
echo "[1] Modifikasi konfigurasi Nginx untuk menambahkan X-Real-IP"
echo "=============================="

# Path default konfigurasi nginx
NGINX_CONF="/etc/nginx/sites-available/default"

# Backup dulu konfigurasi lama
cp $NGINX_CONF ${NGINX_CONF}.bak

# Ubah konfigurasi nginx
cat > $NGINX_CONF <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.php index.html index.htm;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param X-Real-IP $remote_addr;  # Tambahkan ini!
        include fastcgi_params;
    }
}
EOF

echo "✅ Konfigurasi Nginx sudah diperbarui"

echo "=============================="
echo "[2] Modifikasi index.php untuk menampilkan IP pengunjung"
echo "=============================="

cat > /var/www/html/index.php <<'EOF'
<?php
$hostname = gethostname();
$ip_pengunjung = $_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR'];
echo "<h1>Selamat datang di taman digital para peri 🌿</h1>";
echo "<p>Hostname: $hostname</p>";
echo "<p>IP Pengunjung: $ip_pengunjung</p>";
?>
EOF

echo "✅ index.php sudah diperbarui"

echo "=============================="
echo "[3] Restart nginx & php-fpm"
echo "=============================="
service nginx restart
service php8.4-fpm restart

echo "✅ Semua selesai. Silakan tes dengan:"
echo "   curl http://$(hostname -s).k08.com:<port>"
