#!/usr/bin/env bash

case "$5" in

    "httpd")
        mkdir /etc/httpd/ssl 2>/dev/null
        openssl genrsa -out "/etc/httpd/ssl/$1.key" 1024 2>/dev/null
        openssl req -new -key /etc/httpd/ssl/$1.key -out /etc/httpd/ssl/$1.csr -subj "/CN=$1/O=Vagrant/C=UK" 2>/dev/null
        openssl x509 -req -days 365 -in /etc/httpd/ssl/$1.csr -signkey /etc/httpd/ssl/$1.key -out /etc/httpd/ssl/$1.crt 2>/dev/null

        block="
        <VirtualHost *:${3:-80}>
            ServerAdmin acasey@panda-group.com
            ServerName $1
            DocumentRoot $2

            ErrorLog logs/$1-error.log
            CustomLog logs/$1-access.log common
            LogLevel warn

            <Directory $2>
              Options -Indexes -Includes -FollowSymLinks SymLinksifOwnerMatch ExecCGI MultiViews
              AllowOverride All
              Order allow,deny
              Allow from all
           </Directory>
        </VirtualHost>
        <VirtualHost *:${4:-443}>
            ServerAdmin acasey@panda-group.com
            ServerName $1
            DocumentRoot $2

            SSLEngine on
            SSLCertificateFile /etc/httpd/ssl/$1.crt
            SSLCertificateKeyFile /etc/httpd/ssl/$1.key

            ErrorLog logs/$1-ssl-error.log
            CustomLog logs/$1-ssl-access.log common
            LogLevel warn

            <Directory $2>
              Options -Indexes -Includes -FollowSymLinks SymLinksifOwnerMatch ExecCGI MultiViews
              AllowOverride All
              Order allow,deny
              Allow from all
           </Directory>
        </VirtualHost>
        "

        echo "$block" > "/etc/httpd/conf/vhosts/available/$1.conf"
        ln -fs "/etc/httpd/conf/vhosts/available/$1.conf" "/etc/httpd/conf/vhosts/enabled/$1.conf"
        service httpd restart
        service php-fpm restart

        ;;

    "nginx")
        mkdir /etc/nginx/ssl 2>/dev/null
        openssl genrsa -out "/etc/nginx/ssl/$1.key" 1024 2>/dev/null
        openssl req -new -key /etc/nginx/ssl/$1.key -out /etc/nginx/ssl/$1.csr -subj "/CN=$1/O=Vagrant/C=UK" 2>/dev/null
        openssl x509 -req -days 365 -in /etc/nginx/ssl/$1.csr -signkey /etc/nginx/ssl/$1.key -out /etc/nginx/ssl/$1.crt 2>/dev/null

        block="server {
            listen ${3:-80};
            listen ${4:-443} ssl;
            server_name $1;
            root \"$2\";

            index index.html index.htm index.php;

            charset utf-8;

            location / {
                try_files \$uri \$uri/ /index.php?\$query_string;
            }

            location = /favicon.ico { access_log off; log_not_found off; }
            location = /robots.txt  { access_log off; log_not_found off; }

            access_log off;
            error_log  /var/log/nginx/$1-error.log error;

            sendfile off;

            client_max_body_size 100m;

            location ~ \.php$ {
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:/var/run/php5-fpm.sock;
                fastcgi_index index.php;
                include fastcgi_params;
                fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                fastcgi_intercept_errors off;
                fastcgi_buffer_size 16k;
                fastcgi_buffers 4 16k;
                fastcgi_connect_timeout 300;
                fastcgi_send_timeout 300;
                fastcgi_read_timeout 300;
            }

            location ~ /\.ht {
                deny all;
            }

            ssl_certificate     /etc/nginx/ssl/$1.crt;
            ssl_certificate_key /etc/nginx/ssl/$1.key;
        }
        "

        echo "$block" > "/etc/nginx/sites-available/$1"
        ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"
        service nginx restart
        service php5-fpm restart

        ;;

esac
