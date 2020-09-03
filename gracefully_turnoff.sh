cd app/prod/kibana
make purge
cd ../../..
cd app/prod/logstash
make purge
cd ../../..
cd app/prod/elasticsearch
make purge
minikube stop
docker container stop gogs 
docker container stop jenkins 