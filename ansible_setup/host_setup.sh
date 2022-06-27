#!/bin/bash

ssh-keygen -q -t rsa -f /home/ansible/.ssh/id_rsa -N ''

ansible all -m user -a "name=norman state=present password={{ 'password' | password_hash('sha512', 'mysecretsalt') }}" --extra-vars "ansible_user=root ansible_password=password"

ansible all -m shell -a "echo 'norman ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/norman" --extra-vars "ansible_user=root ansible_password=password"

ansible all -m authorized_key -a "user=norman state=present key={{ lookup('file', '/home/ansible/.ssh/id_rsa.pub') }}" --extra-vars "ansible_user=root ansible_password=password"

ansible all -m ping