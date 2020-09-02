Deploy prerequisites
====================

SSH into the box:
  sudo mkdir /mnt/challenge
  sudo mount -t vboxsf Challenge /mnt/challenge
  cd /mnt/challenge/1\ -\ prerequisites/
  chmod +x deploy_prereq.sh
  ./deploy_prereq.sh
  

  
  At this step just launch the playbook

ansible-playbook -i ../1\ -\ prerequisites/hosts supporting_infra.yaml 

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
  
  
