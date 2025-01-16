# geoserver
A simple Helm chart for GeoServer


## TL;DR;

```bash
$ helm repo add ncsa https://opensource.ncsa.illinois.edu/charts/
$ helm install geoserver ncsa/geoserver
```

## Prerequisites

- Kubernetes 1.16+
- helm 3
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release ncsa/geoserver
```

The command deploys GeoServer on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

Below are the supported configuration options that can be overridden or customized in `values.yaml`:

| Key | Description | Default Value                 |
| --- | --- |-------------------------------|
| `persistence.accessModes` | The access mode with which to mount elasticsearch data | `ReadWriteOnce`               |
| `persistence.storageClass` | The storage class to use to provision the elasticsearch data PVC | (empty - use cluster default) |
| `persistence.capacity` | The size of the PVC to provision for elasticsearch data | `10Gi`                        |
| `persistence.existingClaim` | An existing claim to use | None                          |
| `image.repository` | The Docker image repo/name to run | `docker.osgeo.org/geoserver`  |
| `image.tag` | The Docker image tag to run, leave blank to use app version | `""`                          |
| `image.pullPolicy` | The Docker image pullPolicy to use when running | `IfNotPresent`                |
| `ingress.enabled` | Whether an ingress rule should be deployed for geoserver | `false`                       |
| `ingress.host` | The hostname to use for the ingress rule | `geoserver.local`             |
| `resources` | [Resource limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) that should be applied to elasticsearch instances | None                          |
| `nodeSelector` | [Node selector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector) that should be applied to elasticsearch instances | None                          |
| `tolerations` | [Tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) that should be applied to elasticsearch instances | None                          |
| `affinity` | [Affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) that should be applied to elasticsearch instances | None                          |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set image.tag=2.23.1 \
    ncsa/geoserver
```

The above command sets the geoserver image's tag to `2.23.1`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml ncsa/geoserver
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

Geoserver can use a disk storage.

### Existing PersistentVolumeClaims

1. Create the PersistentVolume
1. Create the PersistentVolumeClaim
1. Install the chart

```bash
$ helm install --set persistence.existingClaim=PVC_NAME geoserver
```

## ChangeLog

### 1.1.2
- Added an ability of installation of the extensions
- Added variables for CORS configuration

### 1.1.1
- Updated probe checks for the deployment due to the geoserver version update

### 1.1.0
- Added extra configuration option for setting Java memory heap size.
- Fixed bugs in the chart
- Port name changed to 'geoserver' from 'http'

### 1.0.0
- Initial release of helm chart

### 0.2.0
- Test version of helm chart

### 0.1.0 
- IGNORE, this is a typo, should be 1.0.0
