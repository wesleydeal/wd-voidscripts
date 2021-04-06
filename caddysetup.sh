#!/bin/sh
[ -w / ] || { echo "ERROR: Invoke this script as root. Exiting." ; exit 1 ; }
wget "https://caddyserver.com/api/download?os=linux&arch=amd64" -O /usr/bin/caddy
mkdir /etc/sv/caddy
echo "#!/bin/sh" >> /etc/sv/caddy/run
echo "exec 2>&1" >> /etc/sv/caddy/run
echo "cd /var/lib/caddy" >> /etc/sv/caddy/run
echo "exec chpst -u caddy /usr/bin/caddy run --environ --config /etc/caddy/Caddyfile" >> /etc/sv/caddy/run
chmod +x /etc/sv/caddy/run
mkdir /var/log/caddy
echo "#!/bin/sh" >> /etc/sv/caddy/log/run
echo "exec svlogd -tt /var/log/caddy" >> /etc/sv/caddy/log/run
chmod +x /etc/sv/caddy/log/run
groupadd --system caddy
useradd --system --gid caddy --create-home --home-dir /var/lib/caddy --shell /usr/sbin/nolgin --comment "Caddy web server" caddy
mkdir /etc/caddy
chown caddy:caddy /etc/caddy
echo "localhost { " >> /etc/caddy/Caddyfile
echo "	root * /var/www" >> /etc/caddy/Caddyfile
echo "	file_server" >> /etc/caddy/Caddyfile
echo "	encode zstd gzip" >> /etc/caddy/Caddyfile
echo "} " >> /etc/caddy/Caddyfile
ln -s /etc/sv/caddy /var/service/
