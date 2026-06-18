.PHONY: values-template
values-template: $(name)
	NAME=$(name) gomplate < gomplate-values.yaml > $(name)/gomplate-values.yaml

clean:
	rm -f $(name)/$(name)-postgres.secret.yaml
	rm -f $(name)/$(name)-minio.secret.yaml
	rm -f $(name)/$(name)-oauth2.secret.yaml
	rm -f $(name)/$(name)-postgres.sealed.yaml
	rm -f $(name)/$(name)-minio.sealed.yaml
	rm -f $(name)/$(name)-oauth2.sealed.yaml
	rm -f $(name)/$(name)-application.yaml
	rm -f $(name)/values.yaml
	rm -f $(name)/keycloak-client.json

.PHONY: mlflow
mlflow: $(name) $(name)/$(name)-postgres.secret.yaml $(name)/$(name)-minio.secret.yaml $(name)/$(name)-oauth2.secret.yaml $(name)/keycloak-client.json $(name)/$(name)-application.yaml $(name)/values.yaml

$(name):
	mkdir $(name)

$(name)/$(name)-application.yaml: $(name)/gomplate-values.yaml
	gomplate -t _helpers.tpl -d Template=$(name)/gomplate-values.yaml < application.yaml > $(name)/$(name)-application.yaml

$(name)/values.yaml: $(name)/gomplate-values.yaml
	gomplate -t _helpers.tpl -d Template=$(name)/gomplate-values.yaml < values.yaml > $(name)/values.yaml

$(name)/keycloak-client.json: $(name)/gomplate-values.yaml
	gomplate -t _helpers.tpl -d Template=$(name)/gomplate-values.yaml < keycloak-client.json > $(name)/keycloak-client.json


$(name)/$(name)-postgres.secret.yaml: $(name)/gomplate-values.yaml
	gomplate -t _helpers.tpl -d Template=$(name)/gomplate-values.yaml < postgres.secret.yaml > $(name)/$(name)-postgres.secret.yaml
	kubeseal < $(name)/$(name)-postgres.secret.yaml > $(name)/$(name)-postgres.sealed.yaml

$(name)/$(name)-minio.secret.yaml: $(name)/gomplate-values.yaml
	gomplate -t _helpers.tpl -d Template=$(name)/gomplate-values.yaml < minio.secret.yaml > $(name)/$(name)-minio.secret.yaml
	kubeseal < $(name)/$(name)-minio.secret.yaml > $(name)/$(name)-minio.sealed.yaml

$(name)/$(name)-oauth2.secret.yaml: $(name)/gomplate-values.yaml
	gomplate -t _helpers.tpl -d Template=$(name)/gomplate-values.yaml < oauth2.secret.yaml > $(name)/$(name)-oauth2.secret.yaml
	kubeseal < $(name)/$(name)-oauth2.secret.yaml > $(name)/$(name)-oauth2.sealed.yaml
