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
│       └── update-geoserver-version.yml
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
└── templates/             # Kubernetes manifest templates
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
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

### 5. Charts Not in Git

The following charts are currently not tracked in git and should be ignored:
- `charts/hedgedoc/`
- `charts/swagger/`
- `charts/uptime-kuma/`

These may be works in progress or local development charts.

## Tracked Charts

Currently managed charts (in git):
- **elasticsearch2** - Elasticsearch 2.x deployment
- **fah** - Folding@Home distributed computing
- **geoserver** - GeoServer geospatial data server
- **mlflow** - MLflow machine learning platform

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
