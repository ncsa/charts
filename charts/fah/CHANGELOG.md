# Changelog

All notable changes to this Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-15

### Added
- Initial release of Folding@Home Helm chart
- Support for CPU-only DaemonSet with configurable resources
- Support for GPU DaemonSet with NVIDIA runtime support
- Read-only root filesystem support for enhanced security
- Configurable storage with hostPath for persistent data
- Network policy for ingress/egress control
- PriorityClass configuration for low-priority workloads
- Secret management with support for existing secrets or in-chart creation
- Comprehensive documentation (README.md, NOTES.txt)
- Support for online account management via Folding@Home web dashboard
- Configurable timezone, username, and team settings
- Web interface access on port 7396

### Security
- Read-only root filesystem enabled by default
- Minimal container capabilities (SETUID, SETGID, CHOWN only)
- Network policy restricting traffic to DNS, HTTP, and HTTPS
- No privilege escalation allowed
- seccompProfile set to RuntimeDefault
