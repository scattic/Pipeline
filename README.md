DevOps Pipeline Playground
==========================

Intro
-----

This repository contains code for a IaaC/CaaC deployment of ELK & Beats on Kubernetes, along with provisioning
supporting infrastructure with Ansible and setting up a Jenkins pipeline to tie all pieces together.

To replicate the playground environment you should follow the steps below, in order.

Prerequisites
-------------

1. Start with a freshly installed VM of Ubuntu Server 20.04. [VirtualBox](https://www.virtualbox.org/) is a nice hypervisor to host the VM.

2. Clone [this git repo](https://github.com/scattic/pipeline) into a folder, or mount the folder with the repo contents from the host. If/when you see */mnt/challenge* below, that is the root of the source code folder - adapt as needed. 

*Clone*
* git clone https://github.com/scattic/pipeline.git _OR_

*Mount*
* sudo mkdir /mnt/challenge
* sudo mount -t vboxsf _name-of-VBOX-shared-folder_ /mnt/challenge

3. Enable the SSH server if needed (only if you're not on Ubuntu Server).

Supporting infrastructure
-------------------------

**SOLUTION ARCHITECTURE**

_Ubuntu 20.04 VM - LABSRV_
[Docker](https://www.docker.com/):          |                                .1 (network gateway)
-- [GOGS](https://gogs.io/)           |                                .2
-- [Jenkins]()        | network=skynet 100.0.0.0/24    .3
-- [Nikto]()          |                                .4
[Minikube]() for [ELK]()
-- ElasticSearch-0,-1,-2
-- Logstash
-- Kibana                                                P: int 5601 -> ext: 30300 ; NodePort
-- FileBeat
[Ansible]()

1. SSH into the VM (LABSRV)

* cd /mnt/challenge
* ./deploy_prereq.sh

*deploy_prereq.sh* will install Ansible, create the hosts file and then launch the *prereq.yaml* Ansible playbook.

The *prereq.yaml* Ansible playbook will complete several actions, such as:
* install required packages (apt and pip), such as Docker
* create a Docker network (for IP addresses predictibility)
* deploy GOGS in a container, with a persistent volume and forward port 3000
* deploy Jenkins in a container, with a persistent volume and forward port 8080
* deploy Nikto in a container
* download and install minikube and kubectl

After the playbook is finished you'll still need to:

- Get the Jenkins unlock code:
  docker logs CONTAINER_ID
  - install plugins
  - create user zeus

- configured GOGS first-run
  - create user zeus
- create a GOGS repo called challenge

- init the new repo, on the host run:

Go to the app stack folder:

mkdir prod
cd prod
touch README.md
git init
git config user.name "zeus"
git config user.email "zeus@olymp.com"
git add .
git commit -m “frist”
git remote add origin http://localhost:3000/zeus/prod.git
git push -u origin master

- check minikube dashboard
  in one terminal get the url:
  sudo minikube dashboard --url

  open anoher separate session, like:
  ssh -L 18888:127.0.0.1:39181 ladmin@192.168.56.13

  then use a browser:  
  http://localhost:18888/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/#/overview?namespace=default
  
  
