# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this gem adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
n## [0.1.1] - 2026-03-22

### Changed
- Improve source code, tests, and rubocop compliance

## [0.1.0] - 2026-03-21

### Added
- Initial release
- Base58 encoding and decoding of UUIDs via `to_base58` and `from_base58`
- Base62 encoding and decoding of UUIDs via `to_base62` and `from_base62`
- UUID generation with encoding via `generate(:base58)` and `generate(:base62)`
- Validation helpers `valid_base58?` and `valid_base62?`
- Guaranteed roundtrip encoding for all valid UUIDs
