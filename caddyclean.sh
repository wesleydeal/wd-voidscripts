#!/bin/sh
[ -w / ] || { echo "ERROR: Invoke this script as root. Exiting." ; exit 1 ; }

sv down caddy
rm /var/service/caddy
rm -rf /etc/sv/caddy
rm -rf /etc/caddy
rm -rf /var/log/caddy
rm -rf /var/www
userdel caddy
groupdel caddy
groupdel webmaster
rm -rf /var/lib/caddy
