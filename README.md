# DevOps Pipeline Playground

## Intro

This repository contains code for a IaaC/CaaC deployment of ELK & Beats on Kubernetes, along with provisioning
supporting infrastructure with Ansible and setting up a Jenkins pipeline to tie all pieces together.

To replicate the playground environment you should follow the steps below, in order.

**SOLUTION ARCHITECTURE**

```
[[ Ubuntu 20.04 VM - LABSRV ]]
- [Docker]          |                                   .1 (network gateway)
-- {GOGS}           |                                   .2
-- {Jenkins}        |--> network=skynet 100.0.0.0/24    .3
-- {Nikto}          |                                   .4
- [Minikube]
-- {ElasticSearch-0},{-1},{-2}
-- {Logstash}
-- {Kibana}                       P: int 5601 -> ext: 30300 ; NodePort
-- {FileBeat}
- [Ansible]
- [Helm]
```

Components:
* [Docker](https://www.docker.com/)
* [GOGS](https://gogs.io/)
* [Nikto](https://cirt.net/Nikto2) 
* [Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/)
* [ELK](https://www.elastic.co/)
* [Ansible](https://www.ansible.com/)
* [Helm](https://helm.sh/)
* [GOSS](https://github.com/aelsabbahy/goss)


## Prerequisites

1. Start with a freshly installed VM of Ubuntu Server 20.04. [VirtualBox](https://www.virtualbox.org/) is a nice hypervisor to host the VM. 
  * The normal user account should be called 'ladmin', with the password 'P@ssw0rd'
  * In case you create a different account, don't forget to update the Jenkins job
  * And yes, ssh with certificates should be used for auth instead of user & psw, but this is just a playground.
  * VirtualBox VM will have two network adapters, one for NAT (or NAT-network) and a Host-Only adapter. The 192.168.56.0 range represents the Host-Only adapter network.

2. Clone [this git repo](https://github.com/scattic/pipeline) into a folder, or mount the folder with the repo contents from the host. If/when you see */mnt/challenge* below, that is the root of the source code folder - adapt as needed. 

  *Clone*
  * git clone https://github.com/scattic/pipeline.git _OR_

  *Mount*
  * sudo mkdir /mnt/challenge
  * sudo mount -t vboxsf _name-of-VBOX-shared-folder_ /mnt/challenge

3. Enable the SSH server if needed (only if you're not on Ubuntu Server).

## Supporting infrastructure

1. SSH into the VM (LABSRV)

`ssh -L 3000:127.0.0.1:3000 -L 8080:127.0.0.1:8080 -L 5601:127.0.0.1:30300 ladmin@192.168.56.13` 

and then,

```
cd /mnt/challenge
./deploy_prereq.sh
```

*deploy_prereq.sh* will install Ansible, create the hosts file and then launch the *prereq.yaml* Ansible playbook.

The *prereq.yaml* Ansible playbook will complete several actions, such as:
* install required packages (apt and pip), such as Docker
* create a Docker network (for IP addresses predictibility)
* deploy GOGS in a container, with a persistent volume and forward port 3000
* deploy Jenkins in a container, with a persistent volume and forward port 8080
* deploy Nikto in a container
* download and install minikube and kubectl
* start Kubernetes cluster on minikube using existing Docker

After this playbook has completed for _the first time_ you'll need to:

### Configure Jenkins

1. Get the Jenkins unlock code, from LABSRV run: `docker logs jenkins`
2. Using a browser, from the *host* where the LABSRV VM is running, open `http://localhost:8080`
3. Install default plugins
4. Create user zeus/zeus (or anything of your choosing, just remember it)
5. Create a user token for API calls: `http://localhost:8080/user/zeus/configure`

**NOTE**: we'll configure the pipeline job in the next sections, remember that the token you've just created will be called `<USER-API-TOKEN>`.

### Configure GOGS

1. Using a browser, from the *host* where the LABSRV VM is running, open `http://localhost:3000`
2. create a user zeus/zeus
3. create a new repository called 'pipeline'
4. back on LABSRV VM, sync the GitHub clone of this repo with the GOGS copy:

```
cd *folder_where_you_cloned_github*
git remote remove origin
git remote add origin http://localhost:3000/zeus/pipeline.git
git push --set-upstream origin master
```

## Setting up the actual build

1. On LABSRV, in the folder when the source code was cloned:

```
cd app
ansible-playbook -i ../hosts build-prereq.yaml
```

This will launch the build-prereq.yaml Ansible playbook, which performs the following actions:
* Installs Helm v3
* Configures minikube addons
* Downloads latest official Helm charts from Elastic
* Installs GOSS

2. Try to perform a manual deployment, by running:

```
cd prod
ansible-playbook -i ../../hosts deploy-all.yaml
``` 

**NOTE:**: this step is not mandatory, but is a nice checkpoint

3. Configure the Jenkins pipeline job:

* Create a new pipeline job called 'ELK-on-Kubernetes'
    * Set the GitHub project URL: http://100.0.0.2:3000/zeus/pipeline.git/ (? not required)
    * This project is parametrized: variable is DEPLOY and options are: 'everything' and 'changes'
    * Trigger builds remotely (e.g., from scripts), token is 'topsecret'
    * Paste the contents of the Groovy script 'cicd/Jenkinsfile' into the Script text box

4. In GOGS, select the repo:

* Go to Settings, Web Hooks
* Create a new Web Hook, with the url as follows:

```
http://zeus:<USER-API-TOKEN>@100.0.0.3:8080/job/ELK-on-Kubernetes/buildWithParameters?token=topsecret&DEPLOY=changes
```

## Other notes

* The Ansible playbooks which deploy each component of the ELK stack are called `deploy.yaml` and can be found under `./app/prod/<component>`
* Those playbooks are mainly wrappers for calling the Helm charts, via Make.
* Tests are available within the `test.yaml` Ansible playbooks in the same folder as above.
* Tests are written/generated using GOSS, and include functionality and integration.
* `values.yaml` in the component folder contains the values we chose to customize for our deployment
* Under `./app/prod/tests` there are few more tests, such as web-app vulnerability scanning with Nikto.
**NOTE**: Nikto scan has been limited to 60s execution time for ....development efficiency. This limitation would obviously be removed in a production environment.

## Helpful references:
* [https://www.computers.wtf/posts/jenkins-webhook-with-parameters/](https://www.computers.wtf/posts/jenkins-webhook-with-parameters/)