#!/bin/bash

# tested with Ubuntu 20.04

sudo apt update

sudo apt-get install -y samba

sudo cp /Software/smb.conf.template /etc/samba/smb.conf

sudo chown root:root /etc/samba/smb.conf
sudo chmod 0644 /etc/samba/smb.conf

sudo systemctl restart smbd

RANDOM_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 40)

(echo $RANDOM_PASSWORD; echo $RANDOM_PASSWORD) | sudo smbpasswd -s -L rbeede

echo New Samba password is
echo ""
echo $RANDOM_PASSWORD
echo ""


sudo ufw allow proto udp to any port 137 
sudo ufw allow proto udp to any port 138 
sudo ufw allow proto tcp to any port 139 
sudo ufw allow proto tcp to any port 445 