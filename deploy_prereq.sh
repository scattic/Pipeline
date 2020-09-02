#!/bin/bash

cd /mnt/challenge/1\ -\ prerequisites/
sudo apt install -y ansible

sudo touch hosts
sudo chmod 666 hosts
echo [challenge_lab] > hosts
echo localhost ansible_connection=local ansible_sudo_pass=P@ssw0rd new_hostname=labsrv >> hosts
mv hosts ..

ansible-playbook prereq.yaml -i ../hosts
