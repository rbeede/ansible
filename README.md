# ansible

Just a handy ansible setup I use to quickly put together a VM with tools I use.

Clean install of Ubuntu 20.04 64-bit Desktop or server into a VM.

`sudo apt-get install --assume-yes ansible git`

The comma after localhost, is important.
`sudo ansible-pull --verbose --url https://github.com/rbeede/ansible.git --inventory localhost, --tags gui pentest-machine-gui-playbook.yml`

### Alternative method with local copy

`ansible-playbook --connection=local --inventory=localhost, --tags gui pentest-machine-gui-playbook.yml`
