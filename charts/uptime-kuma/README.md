# Uptime Kuma Helm Chart

A Helm chart for deploying [Uptime Kuma](https://github.com/louislam/uptime-kuma), a fancy self-hosted monitoring tool.

## Features

- Monitoring for HTTP(s), TCP, HTTP(s) Keyword, Ping, DNS Record, Push, and more
- Support for 90+ notification services (Telegram, Discord, Slack, email, etc.)
- Reactive and fast UI
- Multiple status pages
- Certificate information tracking
- Proxy support and two-factor authentication

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PersistentVolume support in the cluster

## Installing the Chart

To install the chart with the release name `my-uptime-kuma`:

```bash
helm install my-uptime-kuma ./uptime-kuma
```

## Uninstalling the Chart

To uninstall/delete the `my-uptime-kuma` deployment:

```bash
helm delete my-uptime-kuma
```

## Configuration

The following table lists the configurable parameters of the Uptime Kuma chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Image repository | `louislam/uptime-kuma` |
| `image.tag` | Image tag | `""` (uses appVersion from Chart.yaml) |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Kubernetes service port | `3001` |
| `ingress.enabled` | Enable ingress controller resource | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.hosts` | Hostnames for the ingress | `[uptime-kuma.local]` |
| `persistence.enabled` | Enable persistence using PVC | `true` |
| `persistence.existingClaim` | Use an existing PVC | `nil` |
| `persistence.size` | PVC Storage Request | `4Gi` |
| `persistence.accessMode` | PVC Access Mode | `ReadWriteOnce` |
| `persistence.storageClass` | PVC Storage Class | `""` (default) |
| `resources` | CPU/Memory resource requests/limits | `{}` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```bash
helm install my-uptime-kuma ./uptime-kuma --set service.type=LoadBalancer
```

Alternatively, a YAML file that specifies the values for the parameters can be provided:

```bash
helm install my-uptime-kuma ./uptime-kuma -f values.yaml
```

## Resource Recommendations

Based on observed production usage, Uptime Kuma typically uses:
- **Memory**: ~500MiB steady state
- **CPU**: ~0.3% idle, spikes to 100% during page loads

For production deployments, we recommend setting resource requests and limits:

```yaml
resources:
  limits:
    cpu: 1000m      # Allow full CPU core for page load spikes
    memory: 1Gi     # Headroom above steady state
  requests:
    cpu: 100m       # Low baseline for idle state
    memory: 512Mi   # Matches observed steady state
```

**Note**: Resource usage may vary depending on the number of monitors configured.

## Important: Storage Requirements

### 🔒 WARNING: DO NOT USE NFS FOR STORAGE!

**Uptime Kuma uses SQLite as its database, which requires POSIX-compliant file locking.**

**Network file systems like NFS do NOT properly support the file locking mechanisms required by SQLite and WILL cause database corruption.**

**You MUST use one of the following storage options:**
- Local volumes
- Block storage (AWS EBS, GCE Persistent Disk, Azure Disk, etc.)
- Storage classes that provide proper POSIX file locking support

**DO NOT USE:**
- NFS
- CIFS/SMB network shares
- Other network file systems without proper file locking support

If you experience database corruption, connection errors, or "database is locked" errors, this is most likely caused by using incompatible storage.

### Storage Configuration

To use a specific storage class that provides local/block storage:

```yaml
persistence:
  enabled: true
  size: 4Gi
  storageClass: "local-path"  # or your preferred non-NFS storage class
```

To use an existing PVC:

```yaml
persistence:
  enabled: true
  existingClaim: "my-uptime-kuma-pvc"
```

## Scaling

**Uptime Kuma does NOT support horizontal scaling** due to its use of SQLite as the database backend. The deployment is hardcoded to run exactly 1 replica and this cannot be changed.

## Ingress

To enable ingress and access Uptime Kuma via a domain name:

```yaml
ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: uptime-kuma.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: uptime-kuma-tls
      hosts:
        - uptime-kuma.example.com
```

## Default Credentials

Uptime Kuma does not have default credentials. On first access, you will be prompted to create an admin account.

## Persistence

The chart mounts a Persistent Volume at `/app/data` where Uptime Kuma stores its SQLite database and configuration.

## Links

- [Uptime Kuma GitHub](https://github.com/louislam/uptime-kuma)
- [Uptime Kuma Documentation](https://github.com/louislam/uptime-kuma/wiki)
- [Docker Hub](https://hub.docker.com/r/louislam/uptime-kuma)
