#!/usr/bin/env bashm6

REPOSITORY=https://github.com/1n13s/Challenge
NAME_SERVER=servertest.eastus2.cloudapp.azure.com

clear
echo "Actualizando Sistema"
	sleep 2
	sudo apt update -y
        sudo apt upgrade -y
echo "Instalando NGINX"
	sleep 2
        sudo apt install git
        sudo apt install nginx -y
	sudo ufw allow http
	sudo ufw allow https
	sudo ufw deny from 302.0.113.0/24
	sudo ufw allow 'Nginx Full'
	sudo ufw status
echo "Configurando NGINX"
	sleep 2
	if [[  -d /var/www/$NAME_SERVER ]]; then
               sudo rm -R /var/www/$NAME_SERVER
    fi
	echo "Configuración del certificado ssl"
	apt-get install -y certbot
	sudo certbot certonly \
    -d midominio.com \
    --noninteractive \
    --standalone \
    --agree-tos \
    --register-unsafely-without-email
	cd mkdir /var/www/$NAME_SERVER
	cd /var/www/$NAME_SERVER
	git clone $REPOSITORY
	if [[  -f /etc/nginx/sites-available/$NAME_SERVER  ]]; then
		sudo rm -r /etc/nginx/sites-available/$NAME_SERVER
	fi
	if [[ -f /etc/nginx/sites-enabled/$NAME_SERVER ]]; then
		sudo rm /etc/nginx/sites-enabled/$NAME_SERVER
	fi
	sudo service nginx stop
	cd /etc/nginx/sites-available/
	echo "
	server {
						listen 443 ssl;

						ssl_certificate     /etc/letsencrypt/live/servertest.eastus2.cloudapp.azure.com/fullchain.pem;
						ssl_certificate_key /etc/letsencrypt/live/servertest.eastus2.cloudapp.azure.com/privkey.pem;
						ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
						ssl_ciphers         HIGH:!aNULL:!MD5;

                         root /var/www/$NAME_SERVER/Challenge;

                         index index.html;

                         server_name $NAME_SERVER;

                         access_log /var/log/nginx/$NAME_SERVER.access.log;
                         error_log /var/log/nginx/$NAME_SERVER.example.com.error.log;

                         location / {
                                proxy_http_version 1.1;
                                proxy_set_header Upgrade "\$http_upgrade";
                                proxy_set_header Connection 'upgrade';
                                proxy_set_header Host "\$host";
                                proxy_cache_bypass "\$http_upgrade";
				add_header Access-Control-Allow-Origin "GET";
			}
} " >> $NAME_SERVER
	sudo unlink /etc/nginx/sites-enable/default
	sudo ln -s /etc/nginx/sites-available/$NAME_SERVER /etc/nginx/sites-enabled/
	sudo service nginx restart
	sudo service nginx status

echo "Configurando Keycloak"
	sudo sudo apt-get install default-jre
	#sudo /opt/keycloak-19.0.2/bin/kc.sh start-dev
	sudo cp /var/www/$NAME_SERVER/Challenge/keycloak.service /etc/systemd/system
	sudo groupadd keycloak
	sudo useradd -r -g keycloak -d /opt/keycloak -s /sbin/nologin keycloak
	sudo cd /opt
	sudo chown -R keycloak: keycloak-19.0.2
	sudo chmod o+x /opt/keycloak-19.0.2/bin/
	sudo systemctl daemon-reload
	sudo systemctl enable keycloak
	sudo systemctl start keycloak
	sudo systemctl status keycloak
	sudo service nginx restart
	sudo service nginx status
