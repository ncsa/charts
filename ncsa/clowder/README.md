# Clowder

[Clowder](https://clowderframework.org/) is an open source datamanagement for long tail data.

## TL;DR;

```bash
$ helm install ncsa/clowder
```

## Introduction

Need to be written, this document is still a work in progress.

<!--This chart bootstraps a [Clowder](https://github.com/bitnami/bitnami-docker-rabbitmq) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

Bitnami charts can be used with [Kubeapps](https://kubeapps.com/) for deployment and management of Helm Charts in clusters. This chart has been tested to work with NGINX Ingress, cert-manager, fluentd and Prometheus on top of the [BKPR](https://kubeprod.io/).
-->

## Prerequisites

- Kubernetes 1.16+
- helm 3
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release ncsa/clowder
```

The command deploys Clowder on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation. This will also install MongoDB, RabbitMQ, elasticsearch as well as some extractors.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

Needs to be written

The following table lists the configurable parameters of the Clowder chart and their default values.

| Parameter                            | Description                                      | Default                                                 |
| ------------------------------------ | ------------------------------------------------ | -------------------------------------------------------

The above parameters map to the env variables defined in [bitnami/rabbitmq](http://github.com/bitnami/bitnami-docker-rabbitmq). For more information please refer to the [bitnami/rabbitmq](http://github.com/bitnami/bitnami-docker-rabbitmq) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set rabbitmq.username=admin,rabbitmq.password=secretpassword,rabbitmq.erlangCookie=secretcookie \
    ncsa/clowder
```

The above command sets the RabbitMQ admin username and password to `admin` and `secretpassword` respectively. Additionally the secure erlang cookie is set to `secretcookie`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml ncsa/clowder
```

> **Tip**: You can use the default [values.yaml](values.yaml)

### Production configuration and horizontal scaling

This chart includes a `values-production.yaml` file where you can find some parameters oriented to production configuration in comparison to the regular `values.yaml`.

```console
$ helm install --name my-release -f ./values-production.yaml stable/rabbitmq
```

- Resource needs and limits to apply to the pod:
```diff
- resources: {}
+ resources:
+   requests:
+     memory: 256Mi
+     cpu: 100m
```

- Replica count:
```diff
- replicas: 1
+ replicas: 3
```

- Node labels for pod assignment:
```diff
- nodeSelector: {}
+ nodeSelector:
+   beta.kubernetes.io/arch: amd64
```

- Enable ingress with TLS:
```diff
- ingress.tls: false
+ ingress.tls: true
```

- Start a side-car prometheus exporter:
```diff
- metrics.enabled: false
+ metrics.enabled: true
```

- Enable init container that changes volume permissions in the data directory:
```diff
- volumePermissions.enabled: false
+ volumePermissions.enabled: true
```

To horizontally scale this chart once it has been deployed you have two options:

- Use `kubectl scale` command:

```console
$ kubectl scale statefulset my-release-rabbitmq --replicas=3
```

- Use `helm upgrade` command:

```console
RABBITMQ_PASSWORD="$(kubectl get secret my-release-rabbitmq -o jsonpath='{.data.rabbitmq-password}' | base64 --decode)"
RABBITMQ_ERLANG_COOKIE="$(kubectl get secret my-release-rabbitmq -o jsonpath='{.data.rabbitmq-erlang-cookie}' | base64 --decode)"
$ helm upgrade my-release stable/rabbitmq \
  --set replicas=3 \
  --set rabbitmq.password="$RABBITMQ_PASSWORD" \
  --set rabbitmq.erlangCookie="$RABBITMQ_ERLANG_COOKIE"
```

> Note: please note it's mandatory to indicate the password and erlangCookie that was set the first time the chart was installed to upgrade the chart. Otherwise, new pods won't be able to join the cluster.

### [Rolling VS Immutable tags](https://docs.bitnami.com/containers/how-to/understand-rolling-tags-containers/)

It is strongly recommended to use immutable tags in a production environment. This ensures your deployment does not change automatically if the same tag is updated with a different image.

Bitnami will release a new chart updating its containers if a new version of the main container, significant changes, or critical vulnerabilities exist.

### Load Definitions
It is possible to [load a RabbitMQ definitions file to configure RabbitMQ](http://www.rabbitmq.com/management.html#load-definitions). Because definitions may contain RabbitMQ credentials, [store the JSON as a Kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod). Within the secret's data, choose a key name that corresponds with the desired load definitions filename (i.e. `load_definition.json`) and use the JSON object as the value. For example:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: rabbitmq-load-definition
type: Opaque
stringData:
  load_definition.json: |-
    {
      "vhosts": [
        {
          "name": "/"
        }
      ]
    }
```

Then, specify the `management.load_definitions` property as an `extraConfiguration` pointing to the load definition file path within the container (i.e. `/app/load_definition.json`) and set `loadDefinition.enable` to `true`.

Any load definitions specified will be available within in the container at `/app`.

> Loading a definition will take precedence over any configuration done through [Helm values](#configuration).

## Persistence

The [Bitnami RabbitMQ](https://github.com/bitnami/bitnami-docker-rabbitmq) image stores the RabbitMQ data and configurations at the `/opt/bitnami/rabbitmq/var/lib/rabbitmq/` path of the container.

The chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) at this location. By default, the volume is created using dynamic volume provisioning. An existing PersistentVolumeClaim can also be defined.

### Existing PersistentVolumeClaims

1. Create the PersistentVolume
1. Create the PersistentVolumeClaim
1. Install the chart

```bash
$ helm install --set persistence.existingClaim=PVC_NAME rabbitmq
```

## ChangeLog

### 0.5.0

- update clowder to 1.9.0
- now uses helm3 syntax for chart
- added minio for storage option
- secrets are now passed as environment variables not in configmap
- user creation moved to init container for clowder, will prevent helm chart from timing out.

### 0.2.0

- update clowder to 1.8.0
- make sure to use image.tag for containers

### 0.0.1

This is the first release of the helm chart