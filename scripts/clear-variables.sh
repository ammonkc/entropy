# Clear The Old Environment Variables

sed -i '/# Set Entropy Environment Variable/,+1d' /home/vagrant/.profile
sed -i '/env\[.*/,+1d' /etc/php-fpm.conf
