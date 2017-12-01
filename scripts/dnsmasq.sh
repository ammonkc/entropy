#!/usr/bin/env bash


TLD=`echo $2 | sed -e "s/[^.]*]\?\([^.]*\)/\1/" | cut -d'.' -f 2`

sed -i "s/listen-address=192.168.10.20/listen-address=$1/" /etc/dnsmasq.d/entropy.conf
echo -e "$1 $2." >> /etc/hosts.dnsmasq
echo -e "domain=$TLD" > "/etc/dnsmasq.d/$TLD.conf"
echo -e "local=/$TLD/" >> "/etc/dnsmasq.d/$TLD.conf"
