#!/usr/bin/env bash

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
