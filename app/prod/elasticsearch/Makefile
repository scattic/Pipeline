default: test

include ../../helm-charts/helpers/examples.mk

RELEASE := helm-es-minikube

secrets:
	kubectl delete secret elastic-config-credentials || true
	kubectl create secret generic elastic-config-credentials --from-literal=password=changeme --from-literal=username=elastic

install:
	helm upgrade --wait --timeout=900s --install --values values.yaml $(RELEASE) ../../helm-charts/elasticsearch

test: install goss
	helm test $(RELEASE)

purge:
	helm uninstall $(RELEASE)
