# wd-voidscripts

basic scripts from an amateur user of Void Linux

## basicsetup.sh

Perform basic setup tasks useful for a new system (especially a server). Installs vim, git, wget, installs and enables socklog for logging, chrony for time sync, cronie for cron, prompts to: enable sshd, lock root account (TODO), create/modify a user with wheel and socklog groups.

## caddysetup.sh

Installs the Caddy web server using the latest release from the official site. Creates a service account, sets up logging, and sets up Caddy to run as a service. Creates /var/www owned by the webmaster group.

## caddyclean.sh

Undoes everything caddysetup.sh does. WARNING: this will delete your config for caddy and your /var/www
