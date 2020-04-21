sudo certbot certonly --standalone --preferred-challenges http -d 3.14.6.192.nip.io

sudo mosquitto_passwd -c /etc/mosquitto/passwd ubuntu

sudo nano /etc/mosquitto/conf.d/default.conf

allow_anonymous false
password_file /etc/mosquitto/passwd

listener 1883 localhost

listener 8883
certfile /etc/letsencrypt/live/3.14.6.192.nip.io/cert.pem
cafile /etc/letsencrypt/live/3.14.6.192.nip.io/chain.pem
keyfile /etc/letsencrypt/live/3.14.6.192.nip.io/privkey.pem

listener 8083
protocol websockets
certfile /etc/letsencrypt/live/3.14.6.192.nip.io/cert.pem
cafile /etc/letsencrypt/live/3.14.6.192.nip.io/chain.pem
keyfile /etc/letsencrypt/live/3.14.6.192.nip.io/privkey.pem

sudo nano /etc/letsencrypt/renewal/3.14.6.192.nip.io.conf
