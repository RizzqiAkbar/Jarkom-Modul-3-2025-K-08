#!/bin/bash
# ==============================================
# SOAL NOMOR 12 - Taman Digital Para Penguasa Peri
# Node: Galadriel / Celeborn / Oropher
# ==============================================

echo "=============================="
echo "[1] Update dan install dependensi"
echo "=============================="
apt update -y
apt install -y nginx php8.4-fpm php8.4-cli php8.4-common php8.4-mysql

echo "=============================="
echo "[2] Membuat direktori web root"
echo "=============================="
mkdir -p /var/www/html
chmod -R 755 /var/www/html

echo "=============================="
echo "[3] Membuat file index.php yang menampilkan hostname"
echo "=============================="
cat > /var/www/html/index.php <<'EOF'
<?php
echo "<h1>Selamat datang di taman digital para peri 🌿</h1>";
echo "<p>Hostname: " . gethostname() . "</p>";
?>
EOF

echo "=============================="
echo "[4] Membuat konfigurasi Nginx (blokir akses via IP)"
echo "=============================="
cat > /etc/nginx/sites-available/peri.conf <<'EOF'
server {
    listen 80;
    server_name galadriel.k08.com celeborn.k08.com oropher.k08.com;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    # Blok akses langsung via IP
    if ($host ~* ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$) {
        return 403;
    }
}
EOF

echo "=============================="
echo "[5] Mengaktifkan konfigurasi baru"
echo "=============================="
ln -sf /etc/nginx/sites-available/peri.conf /etc/nginx/sites-enabled/peri.conf
rm -f /etc/nginx/sites-enabled/default

echo "=============================="
echo "[6] Menyalakan dan merestart service"
echo "=============================="
service php8.4-fpm start
service nginx start
service php8.4-fpm restart
service nginx restart

echo "=============================="
echo "[✅] Konfigurasi selesai!"
echo "Coba akses menggunakan domain:"
echo "   → http://galadriel.k08.com"
echo "   → http://celeborn.k08.com"
echo "   → http://oropher.k08.com"
echo ""
echo "[⚠️] Akses melalui IP akan ditolak (403 Forbidden)"
echo "=============================="
