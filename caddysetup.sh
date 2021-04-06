#!/bin/sh
[ -w / ] || { echo "ERROR: Invoke this script as root. Exiting." ; exit 1 ; }

# get caddy and prepare binary
wget "https://caddyserver.com/api/download?os=linux&arch=amd64" -O /usr/bin/caddy
chmod +x /usr/bin/caddy
setcap cap_net_bind_service=+eip /usr/bin/caddy

# create account
groupadd --system caddy
useradd --system --gid caddy --create-home --home-dir /var/lib/caddy --shell /bin/false --comment "Caddy web server" caddy
chmod 755 /var/lib/caddy

# create config directory
mkdir /etc/caddy
chown caddy:caddy /etc/caddy
chmod 755 /etc/caddy
echo "{" >> /etc/caddy/Caddyfile
echo "	auto_https disable_redirects" >> /etc/caddy/Caddyfile
echo "}" >> /etc/caddy/Caddyfile
echo ":80 { " >> /etc/caddy/Caddyfile
echo "	root * /var/www" >> /etc/caddy/Caddyfile
echo "	file_server" >> /etc/caddy/Caddyfile
echo "	encode zstd gzip" >> /etc/caddy/Caddyfile
echo "} " >> /etc/caddy/Caddyfile
ln -s /etc/sv/caddy /var/service/

# create /var/www
mkdir /var/www
groupadd --system webmaster
chown root:webmaster /var/www
chmod 775 /var/www
chmod g+s /var/www
echo "Hello, world!" > /var/www/index.html
chmod 775 /var/www/index.html
chown root:webmaster /var/www/index.html

# create service
mkdir /etc/sv/caddy
echo "#!/bin/sh" >> /etc/sv/caddy/run
echo "exec 2>&1" >> /etc/sv/caddy/run
echo "cd /var/lib/caddy" >> /etc/sv/caddy/run
echo "exec chpst -u caddy /usr/bin/caddy run --environ --config /etc/caddy/Caddyfile" >> /etc/sv/caddy/run
chmod +x /etc/sv/caddy/run

# set up logging
mkdir /var/log/caddy
mkdir /etc/sv/caddy/log
echo "#!/bin/sh" >> /etc/sv/caddy/log/run
echo "exec svlogd -tt /var/log/caddy" >> /etc/sv/caddy/log/run
chmod +x /etc/sv/caddy/log/run

# enable service
ln -s /etc/sv/caddy /var/service/
sleep 5
sv up caddy
sv status caddy
