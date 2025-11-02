#!/bin/bash
echo "===== [SOAL 7] Laravel Worker Setup (Elendil, Isildur, Anarion) ====="
apt-get install -y php8.4 php8.4-fpm php8.4-cli php8.4-mysql php8.4-xml php8.4-mbstring php8.4-zip composer git unzip nginx

mkdir -p /var/www
cd /var/www
git clone https://github.com/elshiraphine/laravel-simple-rest-api.git app-laravel
cd app-laravel
rm -f composer.lock
COMPOSER_MEMORY_LIMIT=-1 composer update --ignore-platform-reqs
cp .env.example .env
php artisan key:generate

sed -i "s|DB_HOST=.*|DB_HOST=192.215.4.102|" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=laravel_app|" .env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=laravel|" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=laravelbaru123|" .env

php-fpm8.4 -D
nginx
echo "[+] Laravel Worker siap digunakan."
