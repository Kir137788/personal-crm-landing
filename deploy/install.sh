#!/usr/bin/env bash
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Run with sudo'; exit 1; }
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y rsync
[[ -x /usr/bin/rrsync ]] || { echo 'Restricted rsync executable missing'; exit 1; }
[[ -d /var/www/krug-landing && ! -L /var/www/krug-landing ]] || { echo 'Landing directory missing or is a symlink'; exit 1; }
chown -R crmapp:crmapp /var/www/krug-landing
chmod 755 /var/www/krug-landing
echo 'Landing deployment directory and restricted rsync are ready.'
