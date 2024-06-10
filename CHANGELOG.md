# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this gem adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-04-03

### Added
- Add `batch_generate(count, format:)` to generate multiple compact IDs at once
- Add `batch_to_base58(uuids)` and `batch_to_base62(uuids)` for bulk UUID encoding
- Add `base58_to_base62(str)` and `base62_to_base58(str)` for direct cross-format conversion
- Add `format?(str)` to detect whether a string is Base58, Base62, or unknown
- Add `decode(str)` to auto-detect format and decode to UUID

## [0.1.7] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.6] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.5] - 2026-03-26

### Fixed
- Add Sponsor badge to README
- Fix license section link format

## [0.1.4] - 2026-03-24

### Changed
- Expand README API table to document all public methods

## [0.1.3] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements
- Remove inline comments from Development section to match template

## [0.1.2] - 2026-03-24

### Fixed
- Fix Installation section quote style to double quotes

## [0.1.1] - 2026-03-22

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
