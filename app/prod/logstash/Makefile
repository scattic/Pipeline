default: install

include ../../helm-charts/helpers/examples.mk

RELEASE := helm-logstash-elasticsearch

install:
	helm upgrade --wait --timeout=900s --install $(RELEASE) --values ./values.yaml ../../helm-charts/logstash

restart:
	helm upgrade --set terminationGracePeriod=121 --wait --timeout=900 --install $(RELEASE) ../../helm-charts/logstash

test: install goss

purge:
	helm uninstall $(RELEASE)
	kubectl delete $$(kubectl get pvc -l release=$(RELEASE) -o name)

