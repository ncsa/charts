# Folding@Home Helm Chart

## Version Information

- **Current Version**: `8.4.9` ([linuxserver/foldingathome:8.4.9](https://hub.docker.com/r/linuxserver/foldingathome/tags))
- **Last Updated**: 2025-10-28

---

A Helm chart for deploying Folding@Home on Kubernetes clusters, supporting both CPU-only and GPU-accelerated folding.

## Overview

Folding@Home is a distributed computing project for disease research. This chart deploys Folding@Home clients as DaemonSets, allowing you to utilize idle CPU and GPU resources across your Kubernetes cluster.

## Features

- **Dual DaemonSet Support**: Separate DaemonSets for CPU-only and GPU-enabled nodes
- **Enhanced Security**: Read-only root filesystem support following LinuxServer.io best practices
- **Flexible Configuration**: Configurable resource limits, team settings, and storage paths
- **Secret Management**: Support for existing secrets or in-chart secret creation
- **Network Policies**: Optional network isolation for security
- **Low Priority**: Uses PriorityClass to allow easy preemption by higher-priority workloads

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- For GPU support: NVIDIA GPU Operator or equivalent with `nvidia` RuntimeClass
- A Folding@Home account (create one at https://app.foldingathome.org/)

## Installation

### Basic Installation

```bash
helm install fah charts/fah/ \
  --set fah.username="your-username" \
  --set fah.team="your-team-number" \
  --set secret.accountToken="your-account-token"
```

### Installation with Custom Values

Create a `values.yaml` file:

```yaml
fah:
  username: "myusername"
  team: "1065368"
  timezone: "America/Chicago"

secret:
  accountToken: "your-token-here"

cpu:
  enabled: true
  resources:
    limits:
      cpu: "4"
      memory: "10Gi"

gpu:
  enabled: true
  resources:
    limits:
      cpu: "2"
      memory: "16Gi"
      gpu: 1
```

Then install:

```bash
helm install fah charts/fah/ -f values.yaml
```

## Configuration

### Core Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `namespace` | Namespace for deployment | `fah` |
| `image.repository` | Container image repository | `linuxserver/foldingathome` |
| `image.tag` | Container image tag | `8.4.9` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Folding@Home Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `fah.username` | Your Folding@Home username | `""` |
| `fah.team` | Team number | `""` |
| `fah.timezone` | Timezone (e.g., "America/Chicago") | `UTC` |
| `fah.puid` | User ID for container | `1000` |
| `fah.pgid` | Group ID for container | `1000` |

### Secret Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `secret.existingSecret` | Use an existing secret with ACCOUNT_TOKEN | `""` |
| `secret.accountToken` | Account token (used if existingSecret is not set) | `""` |

**Getting your account token**: Create an account at https://app.foldingathome.org/ and retrieve your account token from your account settings. This token allows you to manage all your folding machines from the online dashboard.

### CPU DaemonSet

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cpu.enabled` | Enable CPU-only folding | `true` |
| `cpu.resources.requests.cpu` | CPU request | `100m` |
| `cpu.resources.requests.memory` | Memory request | `256Mi` |
| `cpu.resources.limits.cpu` | CPU limit | `""` |
| `cpu.resources.limits.memory` | Memory limit | `10Gi` |

### GPU DaemonSet

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gpu.enabled` | Enable GPU folding | `false` |
| `gpu.resources.requests.cpu` | CPU request | `100m` |
| `gpu.resources.requests.memory` | Memory request | `256Mi` |
| `gpu.resources.limits.cpu` | CPU limit | `""` |
| `gpu.resources.limits.memory` | Memory limit | `16Gi` |
| `gpu.resources.limits.gpu` | Number of GPUs | `1` |

### Storage

| Parameter | Description | Default |
|-----------|-------------|---------|
| `storage.hostPath` | Host path for persistent data | `/var/lib/fah` |

### Security

| Parameter | Description | Default |
|-----------|-------------|---------|
| `security.readOnlyRootFilesystem` | Enable read-only root filesystem | `true` |

### Other Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `priorityClass.value` | Priority value (negative = lower priority) | `-100` |
| `networkPolicy.enabled` | Enable network policy | `true` |
| `webPort` | Web interface port | `7396` |
| `affinity.excludeControlPlane` | Exclude control plane nodes | `true` |

## Examples

### CPU-Only Deployment

```yaml
cpu:
  enabled: true
  resources:
    limits:
      memory: "8Gi"

gpu:
  enabled: false
```

### GPU-Only Deployment

```yaml
cpu:
  enabled: false

gpu:
  enabled: true
  resources:
    limits:
      memory: "16Gi"
      gpu: 1
```

### Using an Existing Secret

```yaml
secret:
  existingSecret: "my-fah-secret"
```

The secret should contain an `ACCOUNT_TOKEN` key:

```bash
kubectl create secret generic my-fah-secret \
  --namespace=fah \
  --from-literal=ACCOUNT_TOKEN='your-token'
```

### Disable Read-Only Filesystem

```yaml
security:
  readOnlyRootFilesystem: false
```

## Accessing the Web Interface

Each pod runs a web interface on port 7396. To access it:

```bash
# List pods
kubectl get pods -n fah

# Port forward to a specific pod
kubectl port-forward -n fah folding-at-home-cpu-xxxxx 7396:7396

# Open in browser
open http://localhost:7396
```

### Initial Setup Required

**IMPORTANT**: After deploying the chart, folding will NOT start automatically. You have two options:

#### Option 1: Online Account Management (Recommended)

If you have configured an account token, you can manage all your machines from the Folding@Home web dashboard:

1. Visit https://apps.foldingathome.org/accounts and log in
2. All your deployed pods will appear automatically as new machines
3. Start folding and enable GPU compute from the web dashboard
4. Changes apply to all your machines at once - no need to configure each pod individually

This is the easiest way to manage multiple machines and is especially convenient for large deployments.

#### Option 2: Individual Pod Configuration

Alternatively, you can configure each pod via its local web interface:

1. **Access the web UI** for each pod (use port-forward command above)
2. **Start folding** by clicking the "Fold" or "Start" button in the web interface
3. **For GPU pods**: You must also enable GPU folding in the settings:
   - Navigate to the configuration/settings page in the web UI
   - Enable GPU compute (this is not enabled by default)
   - Verify the GPU is detected and listed

**Note**: Each pod stores its configuration in the `storage.hostPath` on its node. This means:
- Configuration is persistent across pod restarts
- You only need to configure each node once
- If you add new nodes, you'll need to configure those new pods

## Monitoring

View logs from a pod:

```bash
kubectl logs -n fah folding-at-home-cpu-xxxxx -f
```

Check pod status:

```bash
kubectl get pods -n fah -o wide
```

## Security Considerations

### Read-Only Root Filesystem

By default, this chart runs containers with a read-only root filesystem (`security.readOnlyRootFilesystem: true`). This:

- Prevents persistent modifications to the container
- Limits damage if a container is compromised
- Prevents installation of packages or creation of new user accounts

When enabled:
- `/run` is mounted as tmpfs (in-memory) to allow the application to function
- `/config` remains writable for persistent storage
- `/tmp` is available for temporary files

### Network Policy

When `networkPolicy.enabled: true`, pods are restricted to:
- **Ingress**: Port 7396 from within the cluster only
- **Egress**: DNS (port 53), HTTP (80), and HTTPS (443) only

### Priority Class

The default priority is `-100`, meaning these workloads can be easily preempted by higher-priority pods. This is ideal for utilizing idle cluster resources without impacting critical workloads.

## Uninstallation

```bash
helm uninstall fah
```

Note: This will not remove the namespace or persistent data on host paths. To clean up completely:

```bash
kubectl delete namespace fah
# Manually remove data from storage.hostPath on each node
```

## Troubleshooting

### Pods not starting on GPU nodes

Ensure:
1. NVIDIA GPU Operator is installed
2. RuntimeClass `nvidia` exists: `kubectl get runtimeclass`
3. Nodes have the label `nvidia.com/gpu.present=true`

### No work units being processed

Check:
1. **Folding has been started** - Access the web UI and click "Fold" or "Start"
2. **For GPU pods** - GPU compute is enabled in the web UI settings
3. Username and team are configured correctly
4. Account token is valid
5. Network policy allows outbound HTTPS traffic
6. Check pod logs for errors: `kubectl logs -n fah <pod-name>`

### Read-only filesystem errors

If you encounter errors related to the read-only filesystem, you can disable it:

```yaml
security:
  readOnlyRootFilesystem: false
```

Note: This reduces security but may be necessary for compatibility.

## Contributing

This chart is part of the cluster configuration. To make changes:

1. Update the chart files in `charts/fah/`
2. Test with `helm template` or install in a test namespace
3. Submit changes for review

## License

This chart deploys the LinuxServer.io Folding@Home container image. See:
- https://docs.linuxserver.io/images/docker-foldingathome/
- https://foldingathome.org/

## Resources

- [Folding@Home Project](https://foldingathome.org/)
- [LinuxServer.io Documentation](https://docs.linuxserver.io/images/docker-foldingathome/)
- [Read-Only Containers Guide](https://docs.linuxserver.io/misc/read-only/)
