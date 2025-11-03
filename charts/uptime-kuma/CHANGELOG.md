# Changelog

All notable changes to this Helm chart will be documented in this file.

## [1.2.0] - 2025-11-03

### Added
- Optional NSCD (Name Service Cache Daemon) sidecar for DNS caching (disabled by default)
- Resource limits for NSCD sidecar (50m CPU, 32Mi memory)
- CHOWN and FOWNER capabilities to init container for restricted storage backends
- Documentation in README about expected "Failed to start nscd" log messages

### Changed
- Init container now uses recursive chown/chmod with `-R` flag for proper subdirectory permissions
- NSCD volumes and mounts are now conditional based on `nscd.enabled` flag

### Fixed
- Init container permission handling for storage backends like Cinder CSI that require explicit capabilities

## [1.1.0] - 2025-11-02

### Added
- Kubernetes 1.25+ requirement (`kubeVersion: ">=1.25.0"`)
- Security hardening with read-only root filesystem, fsGroup, non-root user, capability dropping, and seccomp
- EmptyDir volume for `/tmp` to support read-only filesystem
- Cinder CSI support: `fixPermissions` init container to handle restricted storage backends
- `ReadWriteOncePod` access mode support for single-instance deployments
- Enhanced `values.schema.json` with security context properties

### Changed
- Updated prerequisites from Kubernetes 1.19+ to 1.25+
- Changed default `persistence.accessMode` to `ReadWriteOncePod`
- Simplified `ingress.yaml`: removed all version checks, now uses only `networking.k8s.io/v1` API
- Updated README with security features and new configuration parameters

### Fixed
- Init container now uses `securityContext.runAsUser` and `podSecurityContext.fsGroup` variables instead of hardcoded values
- Fixed directory permissions for Cinder CSI (chmod 755 with proper ownership)

## [1.0.0] - 2025-11-02

### Added
- Initial release of Uptime Kuma Helm chart
- Support for Uptime Kuma v2.0.2
- Persistent volume support for SQLite database storage
- Configurable ingress support
- Service account creation
- Comprehensive README with NFS storage warning
- Warning comments in values.yaml about NFS incompatibility
- Deployment strategy set to `Recreate` (required for single-instance SQLite)
- GitHub Actions workflow for automated version updates

### Notes
- **CRITICAL**: Do not use NFS or network storage for persistence - SQLite requires POSIX file locking
- Uptime Kuma does not support horizontal scaling due to SQLite database
- First-time setup requires creating an admin account (no default credentials)
