#!/usr/bin/env bash

rm -Rf ~/.local/share/Trash/*

rm -Rf ~/.cache/vmware
rm -Rf ~/shared-drives/* ~/shared-drives/.*

rm -Rf ~/.cache/google-chrome

rm -Rf ~/.cache/mozilla

sudo rm /root/.bash_history

rm ~/.bash_history
rm ~/.lesshst ~/.viminfo

rm -Rf ~/.aws/

# no secrets in the family
find ~/.ssh -type f \! \( -name known_hosts -o -name config \) -exec rm -f {} \;

kdestroy -A

mwinit --delete

sudo apt-get clean
sudo find /var/cache/cinmn/ -type f -exec rm "{}" \;

# Clean out logs
sudo journalctl --vacuum-size=1M

sudo find /var/log -path /var/log/journal -prune -o -type f -name '*.xz' -o -name '*.gz' -exec rm {} \;

sudo find /var/log -path /var/log/journal -prune -o -type f -name '*.[0-9]' -exec rm {} \;

sudo find /var/log -path /var/log/journal -prune -o -type f -name '*.[0-9].*' -exec rm {} \;

sudo find /var/log -path /var/log/journal -prune -o -type f -exec truncate --no-create --size=0 {} \;

sudo journalctl --vacuum-size=1M

sudo fstrim --verbose --all

# Show any personal files that may still be around
find ~/Downloads ~/Desktop
echo ~/Documents
ls -la ~/Documents

echo "history -c; history -w; reset"
