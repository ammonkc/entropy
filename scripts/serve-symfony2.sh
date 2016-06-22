#!/usr/bin/env bash

mkdir /etc/httpd/ssl 2>/dev/null

PATH_SSL="/etc/httpd/ssl"
PATH_KEY="${PATH_SSL}/${1}.key"
PATH_CSR="${PATH_SSL}/${1}.csr"
PATH_CRT="${PATH_SSL}/${1}.crt"

if [ ! -f $PATH_KEY ] || [ ! -f $PATH_CSR ] || [ ! -f $PATH_CRT ]
then
  openssl genrsa -out "$PATH_KEY" 2048 2>/dev/null
  openssl req -new -key "$PATH_KEY" -out "$PATH_CSR" -subj "/CN=$1/O=Vagrant/C=UK" 2>/dev/null
  openssl x509 -req -days 365 -in "$PATH_CSR" -signkey "$PATH_KEY" -out "$PATH_CRT" 2>/dev/null
fi

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
      <IfModule mod_rewrite.c>
          Options -MultiViews
          RewriteEngine On
          RewriteCond %{REQUEST_FILENAME} !-f
          RewriteRule ^(.*)$ app.php [QSA,L]
      </IfModule>
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
      <IfModule mod_rewrite.c>
          Options -MultiViews
          RewriteEngine On
          RewriteCond %{REQUEST_FILENAME} !-f
          RewriteRule ^(.*)$ app.php [QSA,L]
      </IfModule>
   </Directory>
</VirtualHost>
"

echo "$block" > "/etc/httpd/conf/vhosts/available/$1.conf"
ln -fs "/etc/httpd/conf/vhosts/available/$1.conf" "/etc/httpd/conf/vhosts/enabled/$1.conf"
