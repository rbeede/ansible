#!/usr/bin/env bash


# VM guest specific
rm -Rf ~/.cache/vmware
rm -Rf ~/shared-drives/* ~/shared-drives/.*


# root stuff
sudo rm \
/root/.bash_history \
/root/.lesshst \
/root/.viminfo \
/root/.python_history \


# non-root stuff
rm -Rf ~/.cache/google-chrome

rm -Rf ~/.cache/mozilla

rm -Rf ~/.local/share/Trash/*

rm -f ~/*.log

# no secrets in the family
find ~/.ssh -type f \! \( -name known_hosts -o -name config \) -exec rm -f {} \;

kdestroy -A

rm \
~/.bash_history \
~/.lesshst \
~/.viminfo \
~/.python_history

sudo apt-get clean

# Clean out logs
sudo find /var/log -path /var/log/journal -prune -o -type f -name '*.xz' -o -name '*.gz' -exec rm {} \;

sudo find /var/log -path /var/log/journal -prune -o -type f -name '*.[0-9]' -exec rm {} \;

sudo find /var/log -path /var/log/journal -prune -o -type f -name '*.[0-9].*' -exec rm {} \;

sudo find /var/log -path /var/log/journal -prune -o -type f -exec truncate --no-create --size=0 {} \;

sudo journalctl --vacuum-size=1M


######## Purge
sudo fstrim --verbose --all

########
# Show any personal files that may still be around
find ~/Downloads ~/Desktop
echo ~/Documents
ls -la ~/Documents

echo "history -c; history -w; reset"
