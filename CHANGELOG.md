# Changelog

All notable changes to this Helm chart will be documented in this file.

## [0.1.20] - 2025-06-17
### Added
- Chart icon in `Chart.yaml` for improved metadata.

## [0.1.19] - 2025-06-16
### Added
- Support for task runners via the `runners.enabled` value. Sets the `N8N_RUNNERS_ENABLED` environment variable.

## [0.1.18] - 2025-06-15
### Fixed
- Mount writable cache directory when running with a read-only root filesystem.
- Fetch chart dependencies during CI lint workflow.
- Document running `helm dependency build` before installing the chart.

## [0.1.17] - 2025-06-15
### Added
- Optional PostgreSQL database deployed via the Bitnami subchart.
### Changed
- Documented that `helm dependency build` must be run before enabling the
  bundled database.

### Fixed
- Safely access PostgreSQL secret keys to avoid nil pointer errors.

## [0.1.15] - 2025-06-15
### Fixed
- Mount an emptyDir volume when persistence is disabled so pods start with a read-only filesystem.

## [0.1.14] - 2025-06-15
### Fixed
- Generate encryption key by default so fresh installs succeed without persistence.

## [0.1.9] - 2025-06-14
### Added
- Lifecycle hooks configuration.

## [0.1.8] - 2025-06-14
### Added
- `persistence.existingClaim` value for mounting a pre-created PersistentVolumeClaim.
- Deployment and PVC templates updated to use the provided claim instead of creating a new one.

## [0.1.7] - 2025-06-13
### Added
- Ability to mount extra Secrets and ConfigMaps.

## [0.1.6] - 2025-06-13
### Added
- Encryption key secret configuration.

## [0.1.5] - 2025-06-13
### Added
- PodDisruptionBudget template.

## [0.1.4] - 2025-06-13
### Added
- Optional RBAC Role and RoleBinding resources.

## [0.1.3] - 2025-06-13
### Added
- Configurable NetworkPolicy manifest.

## [0.1.2] - 2025-06-13
### Added
- Reference existing Secret for database password.

## [0.1.1] - 2025-06-13
### Added
- Values schema with Artifact Hub annotation.

## [0.1.0] - 2025-06-13
### Added
- Initial chart version.
