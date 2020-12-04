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
| replicaCount | Number of instances to run of clowder. | 1
| memory | Memory for the clowder application in MB. | 4096
| commKey | Administrator key. This key will give administrator level access to Clowder and is not associated with any user. | ""
| secretKey | Secret key used for cookies. This should be set the same for all clowder instances in a replicated setup. Best is for kubernetes to generate a random key. | ""
| initialAdmins | List of initial admins in clowder, this is a list of email addresses and these will always be admins. | ""
| registerThroughAdmins | Should the admin be required to approve all new users. Setting this to false will result in all new users immediately be given access to Clowder. | true
| idleTimeoutInMinutes | Number of minutes you stay logged into clowder without any interactions. | 30
| extraOptions | List of additional options to be passed to the clowder process. | []
| extraPlugins | List of additional plugins should be enabled. This will allow you to add additional login mechanisms. | []
| extraConfig | List of additional configuration options to set for clowder. | []
| monitor.replicaCount | number of instances to run of monitor. | 1

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set clowderkey=ncsa \
    ncsa/clowder
```

The above command sets the clowder admin key `ncsa`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml ncsa/clowder
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Users

You can add a list of initial users to clowder. For example the following snippet will add an administrator with
email address `admin@example.com` and password `secret`. 

```
users:
  - email: admin@example.com
    password: secret
    firstname: Admin
    lastname: User
    admin: true
```

## Persistence

Clowder can use a disk storage (default) or S3. In case of S3 it can either use an existing bucket, or use minio to
provide the bucket.

### Existing PersistentVolumeClaims

1. Create the PersistentVolume
1. Create the PersistentVolumeClaim
1. Install the chart

```bash
$ helm install --set persistence.existingClaim=PVC_NAME rabbitmq
```

## ChangeLog

### 0.8.0

- update clowder to 1.13.0
- update extractors:
  - extractors-digest to 2.1.6

### 0.7.0

- update clowder to 1.12.2
- can set extra options for clowder `extraOptions`
- can set the memory used by clowder using `memory` (default is 2GB)
- update extractors:
  - extractors-digest to 2.1.5
  - extractors-image-preview to 2.1.5
  - extractors-image-metadata to 2.1.5
  - extractors-audio-preview to 2.1.5
  - extractors-pdf-preview to 2.1.5
  - extractors-video-preview to 2.1.5

### 0.6.2

- update clowder to 1.11.2
- can set replicas for monitor independent from clowder
- update extractors:
  - extractors-digest to 2.1.4
  - extractors-image-preview to 2.1.4
  - extractors-image-metadata to 2.1.4
  - extractors-audio-preview to 2.1.4
  - extractors-pdf-preview to 2.1.4
  - extractors-video-preview to 2.1.4
  - extractors-clamav to 1.0.3

### 0.6.1

- update clowder to 1.11.1
- ability to set idle timeout (default is 30 min)
- use new healthz endpoint in clowder for ready checks.

### 0.6.0

- update clowder to 1.11.0
- update RabbitMQ to 7.6.7
- updated most core extractors to newer version
- added virus checker extractor
- added `extraConfig` and `extraPlugins` to allow finer control of clowder
  - this can be used to add additional login options to clowder
- monitor is now deployed at https://\<server\>/\<path\>/monitor/index.html

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