# Changelog

All notable changes to this Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.1] - 2025-11-02

### Added
- JSON Schema validation for Helm values (values.schema.json)
- GitHub Actions workflow to automate appVersion updates

### Changed
- Updated README documentation

## [1.3.0] - 2025-03-11

### Added
- Configurable PROXY configuration support via proxyBaseUrl

## [1.2.0] - 2025-01-16

### Added
- Support for extension installation with configurable stable extensions
- Support for additional libraries directory
- Support for GeoServer library directory

## [1.1.1] - 2024-11-19

### Changed
- Updated probe checks due to GeoServer upgrade

## [1.1.0] - 2023-12-06

### Added
- Configurable Java memory heap size control via extraJavaOpts

### Fixed
- Fixed a bug in heap size configuration

## [1.0.0] - 2023-11-02

### Added
- Initial release of GeoServer Helm chart
- StatefulSet deployment for GeoServer
- CORS configuration support
- Authentication with configurable username and password
- Whitelist configuration for GUI
- Service account creation
- Ingress configuration
- Startup probe configuration
- Demo data skip option
- Service and persistent volume configuration

### Notes
- Storage warning: Requires block storage, not suitable for NFS
- Tested with GeoServer 2.x versions

## [0.1.0] - 2023-10-20

### Added
- Initial GeoServer chart structure and templates
