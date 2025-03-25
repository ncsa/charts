# Scripts to Make an MLFlow Deployment
Deploying MLFlow using the ArgoCD setup still requires several files and a bit
of carefully copied and pasted config. This directory holds a Makefile and a 
set of Go templates to produce that from just a small handful of config settings.

## Prerequisites
This Makefile assumes you have a go templating engine installed in your shell.
We are using [gomplate](https://docs.gomplate.ca/installing/).

The Makefile uses the `kubeseal` command to encrypt the generated secrets. You
will need to have it installed, and your KubeConfig set to point to the 
cluster you want to deploy to.

## Makefile Argument: name
Each of the Makefile steps expect a single variable setting from the command
line: `name` - this value represents the name of the mlflow deployment and will
be used in a number of contexts:
1. The subdirectory where the files will be generated
2. Root name of the files that eventually will be copied to the `kubernetes` or `charts` directories in the Argo repository
3. Default application name and values group

## Create Initial Settings
The first step in this process is to create the basic values used to drive the
entire templating process.
```shell
% make name=my-mlflow values-template
```
This will create a directory named `my-mlflow` and populate a go template values
file there. This values file will have some defaults based on the name, and show
you all the other fields you can change for your specific deployment.

## Gomplate-values.yaml
Here are the values you can configure for your deployment:

| Property Name                       | Description                                                                                                 | Default                                   |
|-------------------------------------|-------------------------------------------------------------------------------------------------------------|-------------------------------------------|
| name                                | Name for this deployment. Will be used for the Keycloak client ID as well as naming the various K8s objects | The name provided with the `make` command |
| namespace                           | Kubernetes namespace where mlflow will be deployed                                                          | mlflow                                    |
| MLFlow.artifacts.bucketName         | Bucket name where the MLFlow artifacts will be persisted. Must follow bucket naming conventions             | Name provided with make command           |
| OAuth2.enabled                      | Enable the OAuth2-proxy sidecar?                                                                            | true                                      |
| OAuth2.secret                       | Name of a K8s holding the OAuth2 secrets. Leave blank to create public client                               | <blank>                                   |
| OAuth2.allowedGroups                | YAML List of Keycloak groups that will be allowed access                                                    | Some default NCSA LDAP groups             |
| OAuth2.client_secret                | A generated random secret that could be included in the oauth2-secret file if used                          | Random string                             |
| OAuth2.keycloak_realm_url           | The URL to the Keycloak realm we will be authenticating to                                                  | The software-dev MLFlow realm             |
| chartVersion                        | The MLFlow helm chart to use                                                                                | 1.*                                       |
| postgresql.persistence.storageClass | Storage class to be used for the postgres db                                                                | csi-cinder-sc-delete                      |
| minio.persistence.storageClass      | Storage class for minio data                                                                                | nfs-taiga                                 |
| ingress.enabled                     | Enable an ingress to the MLFlow tracking server?                                                            | true                                      |
| ingress.host                        | Hostname for the tracking server ingress                                                                    | A suggested host on software-dev domain   |

Looks the defaulted values over and make changes as needed.

## Generate Deployment
Once you have the values you want, you can generate the deployment files with
```shell
% make name=my-mlflow mlflow
```
This will produce the following files for you:
1. keycloak-client.json - A file you can import into Keycloak to setup the OIDC client
2. $(name)-application.yaml - the Helm application manifest to copy to your `charts/templates` directory in Argo repo
3. $(name)-minio.secret.yaml and $(name)-minio.sealed.yaml - randomly generated secret values for minio as well as the encrypted version of these
4. $(name)-postgres.secret.yaml and $(name)-postgres.sealed.yaml - randomly generated secret values for postgres as well as the encrypted version of these
5. $(name)-oauth2.secret.yaml and $(name)-oauth2.sealed.yaml - randomly generated secret values for oauth2-proxy as well as the encrypted version of these. Delete these if you are not using OAuth2 secrets
6. values.yaml - Fragment of values.yaml to be carefully pasted into the Argo repository values.yaml







