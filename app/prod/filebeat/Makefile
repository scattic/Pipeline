default: test

include ../../helm-charts/helpers/examples.mk

RELEASE := helm-filebeat-default

install:
	helm upgrade --wait --timeout=600s --values values.yaml --install $(RELEASE) ../../helm-charts/filebeat

test: install goss

purge:
	helm uninstall $(RELEASE)
