#!/bin/bash
echo "===== [SOAL 8] Database + Reverse Proxy (Palantir) ====="
apt-get install -y mariadb-server nginx php8.4-fpm php8.4-mysql

# Konfigurasi DB
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
pkill mysqld || true
pkill mysqld_safe || true
rm -f /var/run/mysqld/mysqld.pid
mysqld_safe &

sleep 5
mysql -u root <<EOF
CREATE DATABASE laravel_app;
CREATE USER 'laravel'@'%' IDENTIFIED BY 'laravelbaru123';
GRANT ALL PRIVILEGES ON laravel_app.* TO 'laravel'@'%';
FLUSH PRIVILEGES;
EOF

# Konfigurasi Nginx Reverse Proxy
cat > /etc/nginx/sites-available/k08 <<EOF
upstream laravel_cluster {
    server 192.215.1.101;
    server 192.215.1.102;
    server 192.215.1.103;
}

server {
    listen 80;
    server_name k08.com www.k08.com;

    location / {
        proxy_pass http://laravel_cluster;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

ln -s /etc/nginx/sites-available/k08 /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && nginx

echo "[+] Palantir aktif sebagai DB + Reverse Proxy."
