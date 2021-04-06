#!/bin/sh

[ -w / ] || echo "ERROR: Invoke this script as root. Exiting." || exit 1

echo "wd-voidscripts basic setup for void installations"
echo "this will install basic utilities, updates, socklog as a syslog service, and at your request, enable sshd and lock the root account"
echo "[RETURN] to continue, CTRL+C to quit"
read

echo "Getting latest updates"
xbps-query -Su

echo "Installing basic utilities"
xbps-install -y wget vim git

echo "Installing socklog"
xbps-install -y socklog-void
ln -s /etc/sv/socklog-unix /var/service/
ln -s /etc/sv/nanoklogd /var/service/
sv up socklog-unix
sv up nanoklogd
echo "Check logs with svlogtail or from directory /var/log/socklog"

read -p "Set up an administrative user? [y/N]" yn
case $yn in
	[Yy]* ) echo "Does the user already exist?"
		echo TODO: fix this;;
	* ) echo "No"
		break;;
esac

echo last line
