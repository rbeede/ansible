# ansible

Just a handy ansible setup I use to quickly put together a VM with tools I use.

Clean install of Xubuntu 24.04 64-bit Desktop or Ubuntu server into a VM.

The community.general gets installed with ansible, not ansible-core.
```
sudo apt-get update
sudo apt-get install --assume-yes ansible git
```

The comma at the end of inventory , is important.
```
sudo ansible-pull --url https://github.com/rbeede/ansible.git --inventory `hostname`, --tags all,gui pentest-machine-playbook.yml
```

### Alternative method with local copy

`ansible-playbook --connection=local --inventory=localhost, --tags all,gui pentest-machine-playbook.yml`

### Headless instance (ubuntu-server)
```
sudo ansible-pull --url https://github.com/rbeede/ansible.git --inventory `hostname`, --tags all pentest-machine-playbook.yml
```
