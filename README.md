# Helm Charts

Use this repository to submit NCSA Charts for Helm. Charts are curated application definitions for Helm. For more information about installing and using Helm, see its
[README.md](https://github.com/helm/helm/tree/master/README.md). To get a quick introduction to Charts see this [chart document](https://github.com/helm/helm/blob/master/docs/charts.md).

## Available Charts

This repository currently maintains the following Helm charts:

| Chart | Version | App Version | Description |
|-------|---------|-------------|-------------|
| [elasticsearch2](charts/elasticsearch2) | 0.2.2 | 2.4.6 | Elasticsearch 2.x deployment for legacy applications |
| [fah](charts/fah) | 1.0.2 | 8.4.9 | Folding@Home - Distributed computing for disease research |
| [geoserver](charts/geoserver) | 1.3.0 | 2.26.1 | Open source server for sharing geospatial data |
| [mlflow](charts/mlflow) | 1.2.1 | 2.2.1 | Open source platform for the machine learning lifecycle |
| [uptime-kuma](charts/uptime-kuma) | 1.0.0 | 2.0.2 | Fancy self-hosted monitoring tool with 90+ notification integrations |

### Chart Details

- **elasticsearch2**: Legacy Elasticsearch 2.x chart for applications requiring older Elasticsearch versions
- **fah**: Supports both CPU and GPU DaemonSets for distributed computing with configurable resource limits
- **geoserver**: GeoServer deployment with proxy configuration support and persistent storage options
- **mlflow**: Includes PostgreSQL and MinIO dependencies for complete ML lifecycle management
- **uptime-kuma**: Self-hosted monitoring with HTTP(s)/TCP/Ping monitoring, status pages, and notifications (⚠️ requires local/block storage, no NFS)

For repository management guidelines and automation details, see [AGENTS.md](AGENTS.md).

## Installation

### Adding the NCSA Repository

Add the NCSA chart repository to your Helm client:

```bash
helm repo add ncsa https://opensource.ncsa.illinois.edu/charts/
helm repo update
```

Search available charts:

```bash
helm search repo ncsa
```

### Installing a Chart

Install a chart from the NCSA repository:

```bash
helm install my-release ncsa/<chart-name>
```

For example, to install the Folding@Home chart:

```bash
helm install fah ncsa/fah
```

For more information on using Helm, refer to the [Helm documentation](https://helm.sh/docs/).

## Repository Structure

```
.
├── .github/workflows/    # Automated workflows for chart updates
├── charts/               # Chart source files
│   ├── elasticsearch2/
│   ├── fah/
│   ├── geoserver/
│   ├── mlflow/
│   └── uptime-kuma/
├── AGENTS.md            # Repository guidelines and automation
└── README.md            # This file
```

Each chart directory contains:
- `Chart.yaml` - Chart metadata and version information
- `values.yaml` - Default configuration values
- `README.md` - Chart-specific documentation
- `CHANGELOG.md` - Version history
- `templates/` - Kubernetes manifest templates

## Contributing

We welcome contributions to improve existing charts or add new ones!

### Chart Maintenance Guidelines

- See [AGENTS.md](AGENTS.md) for detailed repository management guidelines
- Each chart has automated version checking via GitHub Actions
- All changes must go through pull requests (no direct pushes)
- Charts should maintain a CHANGELOG.md with version history

### Becoming a Chart Maintainer

To maintain a chart, you need to:

1. Be listed as a maintainer in the chart's `Chart.yaml` file
2. Be invited as a collaborator on this repository
3. Add an `OWNERS` file to the chart directory listing reviewers and approvers

## Pull Request Review Process

- Pull requests require review and approval before merging
- Automated workflows handle version updates and create PRs
- Stale PRs (inactive for 30+ days) will be automatically closed

## Support

For issues or questions:
- Open an [issue](https://github.com/ncsa/charts/issues) in this repository
- Contact the chart maintainers listed in each chart's `Chart.yaml`
