# Changelog

## 0.0.3 - 2022-10-07

### Added

- Events can now be posted to Datadog.

### Changed

- Fixed issue where the `Point` struct name was sent to the metrics endpoint.

## 0.0.2 - 2022-10-07

### Added

- `DateTime` instances are now accepted in the `Point` structure of metrics. The existing integer Unix timestamp option remains.

## 0.0.1 - 2022-10-06

**Initial release**

### Added

- Basic structure for the API client.
- Metrics submit method.
