# Jarkom-Modul-3-2025-K-08

Anggota :
|NRP|NAMA|
|---|---|
|5027241044|Rizqi Akbar Sukirman Putra|
|5027241117|Adinda Cahya Pramesti|


# Topologi Umum

Seluruh jaringan terhubung melalui node utama Durin dan terdiri dari beberapa subnet:

Subnet	Fungsi	Gateway	Node Anggota
192.215.1.0/24	Laravel Worker	192.215.1.1	Elendil, Isildur, Anarion
192.215.2.0/24	PHP Worker	192.215.2.1	Galadriel, Celeborn, Oropher
192.215.3.0/24	DNS (Master–Slave)	192.215.3.1	Erendis, Amdir
192.215.4.0/24	Infrastruktur & Database	192.215.4.1	Aldarion (DHCP), Palantir (DB + Nginx LB)

# Soal 1 – Konfigurasi Dasar Node

Setiap node dikonfigurasi melalui /etc/network/interfaces secara manual.


Contoh konfigurasi di node Elendil:
```
auto eth0
iface eth0 inet static
    address 192.215.1.101
    netmask 255.255.255.0
    gateway 192.215.1.1
    up echo nameserver 192.215.3.101 > /etc/resolv.conf
```

Semua node diarahkan ke DNS utama Erendis (192.215.3.101) agar domain k08.com dapat dikenali.

# Soal 2 – DHCP Server (Aldarion)

Aldarion berperan sebagai DHCP Server utama yang memberikan alamat dinamis untuk node tertentu dan static-mapping untuk beberapa host (fixed address).

```
File: /etc/dhcp/dhcpd.conf
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

File: /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
```

DHCP diuji dengan dhclient -v pada node client dan berhasil memperoleh IP dari range 192.215.4.10–50.

# Soal 3 – DNS Master (Erendis)

Erendis berperan sebagai DNS Master Server untuk domain k08.com.

```
File: /etc/bind/named.conf.local
zone "k08.com" {
    type master;
    file "/etc/bind/db.k08.com";
    allow-transfer { 192.215.3.102; }; # Amdir (Slave)
};

zone "3.215.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.215.3.rev";
};

File: /etc/bind/db.k08.com
$TTL 604800
@ IN SOA ns1.k08.com. root.k08.com. (
    2025103101 604800 86400 2419200 604800 )
    IN NS ns1.k08.com.
    IN NS ns2.k08.com.

ns1 IN A 192.215.3.101
ns2 IN A 192.215.3.102

; Infrastruktur
palantir IN A 192.215.4.102
aldarion IN A 192.215.4.101
elendil IN A 192.215.1.101
isildur IN A 192.215.1.102
anarion IN A 192.215.1.103

@ IN A 192.215.4.102
www IN CNAME k08.com.
```

# Soal 4 – DNS Slave (Amdir)

Amdir adalah DNS Slave yang menerima transfer zona dari Erendis.

```
File: /etc/bind/named.conf.local
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
```

Tes:
```
dig @192.215.3.102 www.k08.com
```

→ Menampilkan IP 192.215.4.102 dengan status NOERROR (sinkronisasi berhasil).

# Soal 5 – TXT & PTR Record

Tambahan record pada DNS Master untuk kebutuhan deskriptif dan reverse mapping.

```
Tambahan di /etc/bind/db.k08.com
cincin IN TXT "Cincin Sauron"
aliansi IN TXT "Aliansi Terakhir"

File Reverse: /etc/bind/db.192.215.3.rev
101 IN PTR ns1.k08.com.
102 IN PTR ns2.k08.com.
```

Tes:
```
dig @192.215.3.101 cincin.k08.com TXT
dig -x 192.215.3.101
```

→ Berhasil menampilkan string TXT dan PTR sesuai konfigurasi.

 Soal 6 – DNS Testing

Dilakukan pengujian name resolution di seluruh node menggunakan:

```
ping k08.com
ping www.k08.com
```

Semua node berhasil resolve ke IP Palantir (192.215.4.102).

# Soal 7 – Laravel Worker Setup

Laravel diinstal pada Elendil, Isildur, dan Anarion.
Versi PHP yang digunakan: 8.4, dengan perbaikan dependency agar kompatibel.

Perintah Instalasi:
```
apt-get install -y php8.4 php8.4-fpm php8.4-cli php8.4-mysql php8.4-xml composer git unzip nginx
cd /var/www
git clone https://github.com/elshiraphine/laravel-simple-rest-api.git app-laravel
cd app-laravel
rm -f composer.lock
COMPOSER_MEMORY_LIMIT=-1 composer update
cp .env.example .env
php artisan key:generate
php-fpm8.4 -D
nginx
```

Laravel berhasil dijalankan pada port 8000 (php artisan serve --host=0.0.0.0).

# Soal 8 – Database & Nginx Reverse Proxy (Palantir)

Palantir berfungsi sebagai Database Server (MariaDB) sekaligus Reverse Proxy Nginx.

Instalasi MariaDB & Nginx:
```
apt-get install -y mariadb-server nginx php8.4-mysql
```

Konfigurasi MySQL:
```
File /etc/mysql/mariadb.conf.d/50-server.cnf:

bind-address = 0.0.0.0


User & DB:

CREATE DATABASE laravel_app;
CREATE USER 'laravel'@'%' IDENTIFIED BY 'laravelbaru123';
GRANT ALL PRIVILEGES ON laravel_app.* TO 'laravel'@'%';
FLUSH PRIVILEGES;

Konfigurasi Laravel Workers (.env)
DB_CONNECTION=mysql
DB_HOST=192.215.4.102
DB_PORT=3306
DB_DATABASE=laravel_app
DB_USERNAME=laravel
DB_PASSWORD=laravelbaru123

Konfigurasi Nginx (Load Balancer)

File /etc/nginx/sites-available/k08:

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
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Tes dari client:
```
lynx http://k08.com
```
→ Menampilkan halaman Laravel default.


# Soal 12
Para Penguasa Peri (Galadriel, Celeborn, Oropher) membangun taman digital mereka menggunakan PHP. Instal nginx dan php8.4-fpm di setiap node worker PHP. Buat file index.php sederhana di /var/www/html masing-masing yang menampilkan nama hostname mereka. Buat agar akses web hanya bisa melalui domain nama, tidak bisa melalui ip.
![WhatsApp Image 2025-11-05 at 18 05 50_edcef6ab](https://github.com/user-attachments/assets/0f4218e1-6b65-4386-bf8c-0d0e257d7ca4)
<img width="2568" height="1319" alt="image" src="https://github.com/user-attachments/assets/17e1bc37-2da4-464a-832e-585e589c1f1b" />
![WhatsApp Image 2025-11-05 at 18 09 02_e1295af1](https://github.com/user-attachments/assets/4ba6a92d-e491-4578-bf07-9df86339d6e2)

### cara running
- echo "192.215.2.201 galadriel.k08.com" >> /etc/hosts
- curl http://galadriel.k08.com ATAU lynx http://galadriel.k08.com
- curl http://192.215.2.201 (harus 403 forbidden karena tidak bisa melalui IP)

# Soal 13
Setiap taman Peri harus dapat diakses. Konfigurasikan nginx di setiap worker PHP untuk meneruskan permintaan file .php ke socket php-fpm yang sesuai. Atur agar Galadriel mendengarkan di port 8004, Celeborn di 8005, dan Oropher di 8006.
![WhatsApp Image 2025-11-05 at 18 11 53_36db3423](https://github.com/user-attachments/assets/d72b2558-c8b4-4412-bae1-d94fac8b65fa)

### cara running
- echo "192.215.2.201 galadriel.k08.com" >> /etc/hosts
- curl http://galadriel.k08.com:8004
- curl http://192.215.2.201:8004

# Soal 14
Keamanan adalah prioritas. Terapkan Basic HTTP Authentication pada nginx di setiap worker PHP, sehingga hanya mereka yang tahu kata sandi (user: noldor, pass: silvan) yang bisa masuk.
![WhatsApp Image 2025-11-05 at 18 24 28_329a57a0](https://github.com/user-attachments/assets/a415328f-b954-432c-9cd5-e16fe67faad3)

### cara running
- curl -u noldor:silvan http://galadriel.k08.com:8004 (pake username sama password)
- curl -u http://galadriel.k08.com:8004 (gapake uname sama password bakal output 401)


# Soal 15
Para Peri ingin tahu siapa yang mengunjungi taman mereka. Modifikasi konfigurasi Nginx di worker PHP untuk menambahkan header X-Real-IP yang akan diteruskan ke PHP. Ubah file index.php untuk menampilkan alamat IP pengunjung asli saat ini.
![WhatsApp Image 2025-11-05 at 18 27 15_f3829d06](https://github.com/user-attachments/assets/04686cc4-cf4e-41ee-9a37-5c6ea2cf1da4)

### cara running
- curl http://Celeborn.k08.com:8005 

# Soal 16
Raja Númenor terakhir yang ambisius, Pharazon, mencoba mengawasi taman-taman Peri. Konfigurasikan Nginx di Pharazon sebagai reverse proxy. Buat upstream Kesatria_Lorien berisi alamat ketiga worker PHP. Atur agar permintaan ke pharazon.<xxxx>.com diteruskan ke backend, dan pastikan konfigurasi Nginx di sPharazon juga meneruskan informasi Basic Authentication yang dimasukkan pengguna ke worker.

### cara running
- curl -u noldor:silvan http://pharazon.k08.com (bisa dicoba dari pharozan atau node lain)


# Soal 17
