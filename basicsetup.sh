#!/bin/sh

[ -w / ] || { echo "ERROR: Invoke this script as root. Exiting." ; exit 1 ; }

echo "\n\nwd-voidscripts basic setup for void installations"
echo "this will install basic utilities, updates, socklog as a syslog service, and at your request, enable sshd and lock the root account"
echo "also todo: swap file, cron, auto updates"
echo "[RETURN] to continue, CTRL+C to quit"
read nothing

echo "\n\nGetting latest updates"
xbps-query -Su

echo "\n\nInstalling basic utilities"
xbps-install -y wget vim git

echo "\n\nInstalling socklog"
xbps-install -y socklog-void
ln -s /etc/sv/socklog-unix /var/service/
ln -s /etc/sv/nanoklogd /var/service/
sv up socklog-unix
sv up nanoklogd
sv status socklog-unix
sv status nanoklogd
echo "Check logs with svlogtail or from directory /var/log/socklog"

echo "\n\nInstalling chrony to sync time"
xbps-install -y chrony
ln -s /etc/sv/chronyd /var/service/
sv up chronyd
sv status chronyd

echo "\n\n"
read -p "Set up an administrative user? [y/N]" yn
case "$yn" in
"[Yy]*" )
	read -p userexists "Does the user already exist? [y/N]"
	read -p username "Enter the username: "
	case "$userexists" in
	"(?![Yy]*)" )
		useradd -m $username
		;;
	esac
	usermod -a -G wheel,socklog $username
	echo "Added $username to wheel,socklog groups"
	echo "For verification, listing all users and associated sudo access:"
	for i in $(awk -F ':' '{print $1}' /etc/passwd ); do sudo -l -U $i ; done
	echo "\nIf $username was not listed as a sudoer, you may need to run visudo and add the wheel group to the list of sudoers"
	;;
esac

echo "\n\n"
read -p "Set up cron? [y/N]" yn
case $yn in
[Yy]* )
	xbps-install -y cronie
	ln -s /etc/sv/cronie /var/service/
	sv up cronie
	sv status cronie
	;;
esac

echo "\n\n"
read -p "Create a swapfile? [y/N]" yn
case $yn in
[Yy]* )
	swapoff -a
	[ test -f /swapfile ] && rm -rf /swapfile
	read -p "Number of Gigabytes for swap file: " swapgigs
	fallocate -l ${swapgigs}G /swapfile
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile
	echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
	swapon --show
	;;
esac

echo "\n\n"
read -p "Enable sshd? [y/N]" yn
case $yn in
[Yy]* )
	ln -s /etc/sv/sshd /var/service/
	sv up sshd
	sv status sshd
	;;
esac

echo Script complete.
