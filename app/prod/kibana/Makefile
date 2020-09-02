default: install
include ../../helm-charts/helpers/examples.mk

RELEASE := helm-kibana-default

install:
	helm upgrade --values=values.yaml --wait --timeout=900s --install $(RELEASE) ../../helm-charts/kibana

test: install goss 

purge:
	helm uninstall $(RELEASE)
