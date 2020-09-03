#!/bin/bash

sudo apt install -y ansible

sudo touch hosts
sudo chmod 666 hosts
echo [challenge_lab] > hosts
echo localhost ansible_connection=local ansible_sudo_pass=P@ssw0rd new_hostname=labsrv >> hosts

ansible-playbook prereq.yaml -i hosts
