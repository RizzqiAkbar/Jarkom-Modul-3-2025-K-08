#!/bin/bash
echo "=============================="
echo "[1] Instalasi nginx (jika belum)"
echo "=============================="
apt-get update -y
apt-get install -y nginx

echo "=============================="
echo "[2] Konfigurasi reverse proxy Pharazon"
echo "=============================="

NGINX_CONF="/etc/nginx/sites-available/default"
cp $NGINX_CONF ${NGINX_CONF}.bak

cat > $NGINX_CONF <<'EOF'
# Konfigurasi Reverse Proxy Pharazon
upstream Kesatria_Lorien {
    server 192.215.2.201:8004;   # Galadriel
    server 192.215.2.202:8005;   # Celeborn
    server 192.215.2.203:8006;   # Oropher
}

server {
    listen 80;
    server_name pharazon.k08.com;

    location / {
        proxy_pass http://Kesatria_Lorien;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Authorization $http_authorization;  # teruskan Basic Auth ke worker
    }
}
EOF

echo "✅ Konfigurasi Nginx Pharazon selesai"

echo "=============================="
echo "[3] Restart nginx"
echo "=============================="
service nginx restart

echo "✅ Reverse proxy aktif di Pharazon"
echo "Silakan uji dengan:"
echo "   curl -u noldor:silvan http://pharazon.k08.com"
