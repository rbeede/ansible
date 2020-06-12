# ansible

Clean install of Ubuntu 20.04 Desktop 64-bit into a VMware VM.

First version is single playbook. Future work will break out into multiple roles so it can be applied to a headless (server only) or desktop environment.

`sudo apt-get install --assume-yes ansible git`

`sudo ansible-pull --verbose --url https://github.com/rbeede/ansible.git --inventory localhost, pentest-machine-playbook.yaml`

### Alternative

`ansible-playbook --connection=local --inventory=localhost, pentest-machine-playbook.yaml`
