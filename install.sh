#!/usr/bin/env bashm6

REPOSITORY=https://github.com/1n13s/Challenge
NAME_SERVER=servertest.eastus2.cloudapp.azure.com
DIRECTORIO=/etc/nginx/sites-available/$NAME_SERVER

clear
echo "Actualizando Sistema"
	sleep 2
	sudo apt update -y
        sudo apt upgrade -y
echo "Instalando NGINX"
	sleep 2
        sudo apt install git
        sudo apt install nginx -y
	sudo ufw allow 'Nginx Full'
	sudo ufw status
echo "Configurando NGINX"
	sleep 2
	if [[  -d /var/www/$NAME_SERVER/public_html ]]; then
               sudo rm -R /var/www/$NAME_SERVER/public_html
        fi
	if [[  -d /var/www/$NAME_SERVER/public_html/Challenge ]]; then
		sudo rm -R /var/www/$NAME_SERVER/public_html/Challenge
	fi
	cd /var/www/$NAME_SERVER
	git clone $REPOSITORY
	if [[  -f /etc/nginx/sites-available/$NAME_SERVER  ]]; then
		sudo rm -r /etc/nginx/sites-available/$NAME_SERVER
	fi
	if [[ -f /etc/nginx/sites-enabled/$NAME_SERVER ]]; then
		sudo rm /etc/nginx/sites-enabled/$NAME_SERVER
	fi
	cd /etc/nginx/sites-available/
	echo "
	server {
                         listen 80;

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
