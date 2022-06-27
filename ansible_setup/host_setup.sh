#!/bin/bash

# non-interactive key creation
ssh-keygen -q -t rsa -f /home/ansible/.ssh/id_rsa -N ''

ansible all -m user -a "name=ansible state=present password={{ 'password' | password_hash('sha512', 'mysecretsalt') }}" --extra-vars "ansible_user=root ansible_password=password"

ansible all -m shell -a "echo 'ansible ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ansible" --extra-vars "ansible_user=root ansible_password=password"

ansible all -m authorized_key -a "user=ansible state=present key={{ lookup('file', '/home/ansible/.ssh/id_rsa.pub') }}" --extra-vars "ansible_user=root ansible_password=password"

ansible all -m ping
