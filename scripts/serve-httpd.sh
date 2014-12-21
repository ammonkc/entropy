#!/usr/bin/env bash

block="
<VirtualHost *:80>
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
"

echo "$block" > "/etc/httpd/conf/vhosts/available/$1.conf"
ln -fs "/etc/httpd/conf/vhosts/available/$1.conf" "/etc/httpd/conf/vhosts/enabled/$1.conf"
service httpd restart
service php-fpm restart
