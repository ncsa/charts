# Changelog

All notable changes to this Helm chart will be documented in this file.

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
