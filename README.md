# Server setup (Manjaro XFCE)

Ansible playbook used to install and customise manjaro

## Bootstrap

Do not run this as root! Run this as a standard user!

```
./bootstrap.sh
```

## Install

Do not run this as root! Run this as a standard user!

```
ansible-playbook -Ki inventory.ini setup.yml
```
