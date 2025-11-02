# AGENTS.md - Chart Repository Guidelines

> **Note**: This document should be updated whenever new rules, patterns, or guidelines are discovered during development or maintenance of the charts. Keep it current as the source of truth for repository conventions.

## Directory Structure

This repository contains Kubernetes Helm charts organized in the following structure:

```
.
├── .github/
│   └── workflows/          # GitHub Actions workflows for automation
│       ├── release.yml     # Chart release workflow
│       ├── update-fah-version.yml
│       ├── update-geoserver-version.yml
│       └── update-uptime-kuma-version.yml
├── charts/                 # All Helm charts
│   ├── elasticsearch2/
│   ├── fah/
│   ├── geoserver/
│   ├── mlflow/
│   ├── hedgedoc/          # Not in git (ignored)
│   ├── swagger/           # Not in git (ignored)
│   └── uptime-kuma/       # Not in git (ignored)
├── README.md
├── makecharts.sh
└── package.sh
```

### Chart Directory Structure

Each chart directory should follow this standard structure:

```
charts/<chart-name>/
├── .helmignore            # Files to ignore when packaging
├── Chart.yaml             # Chart metadata (version, appVersion, etc.)
├── CHANGELOG.md           # Version history and changes
├── README.md              # Chart documentation
├── values.yaml            # Default configuration values
├── values.schema.json     # JSON Schema for values validation (Helm 3+)
└── templates/             # Kubernetes manifest templates
    ├── deployment.yaml (or statefulset.yaml)
    ├── service.yaml
    ├── ingress.yaml
    ├── pvc.yaml (if applicable)
    └── ...
```

## Chart Management Guidelines

### 1. GitHub Actions Automation

**Each chart MUST have its own GitHub Actions workflow** in `.github/workflows/` to automate updates:

- Workflow file naming: `update-<chart-name>-version.yml`
- Purpose: Check for new versions of the application and create PRs with updates
- Schedule: Typically runs weekly (configurable via cron)
- Manual trigger: Must support `workflow_dispatch` for on-demand runs

Example workflows:
- `.github/workflows/update-fah-version.yml`
- `.github/workflows/update-geoserver-version.yml`

### 2. Version Management

#### Chart Version Bumping

When making changes to a chart:

1. **Check for pending changes**: Run `git status` in the chart directory
2. **If NO pending changes exist**: Bump the chart version (patch) in `Chart.yaml`
3. **If pending changes exist**: Do NOT bump the version (changes are already tracked)

Version format: `MAJOR.MINOR.PATCH`
- **MAJOR**: Breaking changes
- **MINOR**: New features, backwards compatible
- **PATCH**: Bug fixes, minor updates

#### Automated Version Updates

The GitHub Actions workflows automatically:
- Update `appVersion` in `Chart.yaml` when new upstream versions are detected
- Bump the chart `version` (patch increment)
- Update documentation in `README.md`
- Create a pull request (never push directly to main)

### 3. Changelog Requirements

**Each chart MUST maintain a `CHANGELOG.md` file** documenting all changes:

Format:
```markdown
# Changelog

## [Chart Version X.Y.Z] - YYYY-MM-DD

### Added
- New features

### Changed
- Changes to existing functionality

### Fixed
- Bug fixes

### Updated
- Updated appVersion from A.B.C to D.E.F

## [Previous Version] - YYYY-MM-DD
...
```

Update the changelog:
- When bumping chart versions
- When changing functionality
- When updating application versions
- When fixing bugs

### 4. Git Workflow Restrictions

**IMPORTANT**: You (agents/automation) can NEVER push directly to GitHub:

- All changes MUST go through pull requests
- Automated workflows create PRs using `peter-evans/create-pull-request` action
- Human review and approval required before merging
- Branch protection recommended on `main`

### 5. Required Chart Files

**Every chart MUST include the following files:**

- **Chart.yaml** - Chart metadata (name, version, appVersion, maintainers, etc.)
- **CHANGELOG.md** - Version history following the format in section 3
- **README.md** - Comprehensive documentation including:
  - Chart description and features
  - Prerequisites
  - Installation instructions
  - Configuration table with all parameters
  - Storage requirements and warnings (if applicable)
  - Scaling information
  - Ingress examples
  - Links to upstream project
- **values.yaml** - Default configuration values with extensive comments
- **values.schema.json** - JSON Schema for Helm 3+ validation (recommended)
- **templates/** directory with Kubernetes manifests
  - Must include: deployment/statefulset, service
  - Should include: ingress, serviceaccount, NOTES.txt
  - May include: pvc, configmap, secret, hpa, etc.

### 6. Charts Not in Git

The following charts are currently not tracked in git and should be ignored:
- `charts/hedgedoc/`
- `charts/swagger/`

These may be works in progress or local development charts.

## Tracked Charts

Currently managed charts (in git):
- **elasticsearch2** - Elasticsearch 2.x deployment
- **fah** - Folding@Home distributed computing
- **geoserver** - GeoServer geospatial data server
- **mlflow** - MLflow machine learning platform
- **uptime-kuma** - Uptime Kuma monitoring tool (fancy self-hosted monitoring)

### Adding a New Chart

When adding a new chart to the repository:

1. Create the chart directory structure under `charts/<chart-name>/`
2. Include all required files: `Chart.yaml`, `CHANGELOG.md`, `README.md`, `values.yaml`, `templates/`
3. Create a GitHub Actions workflow file: `.github/workflows/update-<chart-name>-version.yml`
4. **Update the root `README.md`** file:
   - Add the chart to the "Available Charts" table with version, app version, and description
   - Add details about the chart in the "Chart Details" section
5. Update this `AGENTS.md` file to include the new chart in the "Tracked Charts" list
6. Commit and create a pull request (never push directly)

## Workflow Example: Updating a Chart

1. Automated workflow detects new version
2. Workflow updates:
   - `Chart.yaml` (appVersion + chart version bump)
   - `README.md` (version information)
   - Other relevant files
3. Workflow updates `CHANGELOG.md` with changes
4. Workflow creates pull request
5. Human reviews PR
6. Human merges PR (no automated merging)

## Best Practices

- Keep changelogs up to date with each version
- Use semantic versioning consistently
- Test charts before merging PRs
- Document all configuration options in README
- Maintain backwards compatibility when possible
- Use `helm lint` and `helm test` in CI/CD
- Always create `values.schema.json` for input validation
- Keep resource requests/limits commented in values.yaml but provide recommendations in README
- Add resource usage observations from real deployments to documentation

## Important Patterns and Conventions

### Single-Instance Applications (e.g., SQLite-based apps)

For applications that don't support horizontal scaling:

1. **Use Deployment, not StatefulSet** - If only running 1 replica, Deployment is simpler
2. **Set `strategy.type: Recreate`** - Ensures old pod terminates before new one starts
3. **Hardcode `replicas: 1`** - Don't use a configurable replicaCount value
4. **Remove autoscaling** - Don't include HPA templates or autoscaling values
5. **Document why** - Explain in README and values.yaml comments why scaling is disabled

### Storage Warnings

When storage has specific requirements (e.g., no NFS):

1. **Add prominent warnings** in multiple locations:
   - values.yaml (in comments above persistence section)
   - README.md (dedicated warning section with emoji/formatting)
   - NOTES.txt (shown on every helm install/upgrade)
   - CHANGELOG.md (in Notes section for initial release)
2. **Explain consequences** - State what happens if requirements aren't met (e.g., database corruption)
3. **Provide alternatives** - List acceptable storage types

### values.schema.json

Always include a JSON Schema for Helm 3+ validation:

- Validates types (string, boolean, integer, object, array)
- Enforces enums for constrained values (e.g., service.type)
- Pattern matching for formatted strings (e.g., resource sizes, storage sizes)
- Provides descriptions that UI tools can display
- Helps catch configuration errors before deployment

### Resource Recommendations

- Keep resources commented out in values.yaml (Helm best practice)
- Add a "Resource Recommendations" section to README with:
  - Observed real-world usage data
  - Recommended requests and limits for production
  - Explanation of why those values were chosen
  - Note that usage may vary based on workload

### Bitnami Dependencies

**Important distinction between Bitnami chart repository and Bitnami Legacy Docker images:**

- **Helm Charts**: Continue using `https://charts.bitnami.com/bitnami` for chart dependencies
- **Docker Images**: Use `docker.io/bitnamilegacy` registry for legacy Docker images (if needed)

As of August 2025, Bitnami restructured its offerings:
- **Bitnami Mainline** (`docker.io/bitnami`) - Contains only hardened images for development with latest tags
- **Bitnami Legacy** (`docker.io/bitnamilegacy`) - Archives older versioned tags no longer maintained
- **Helm Charts** - Still available at `https://charts.bitnami.com/bitnami` (OCI artifacts)

**When to use bitnami-legacy Docker images:**
- Only as a temporary workaround for applications depending on specific older versions
- Not recommended for long-term production use (no updates or security patches)
- For production, consider subscribing to Bitnami Secure Images or migrating to maintained alternatives

**Example usage in values.yaml:**
```yaml
oauth2Proxy:
  repository: "bitnamilegacy/oauth2-proxy"  # Legacy Docker image
  tag: "7.4.0"
```

Reference: https://github.com/bitnami/containers/issues/83267
