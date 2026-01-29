# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.4] - 2026-01-29

### Modified
- Release sent to generate a new binary version of the built files.

## [0.1.3] - 2026-01-29

### Modified
- Updated Cargo build to be compatible with rustler_precompiled.

## [0.1.2] - 2026-01-29

### Added
- Added `rustler_precompiled` to use the lib without `rustler` as a dep.

## [0.1.1] - 2026-01-27

### Added
- Added `ex_doc` to publish in `hex.pm`.

## [0.1.0] - 2026-01-27

### Added
- Initial release
- ByteTrack implementation from trackforge
- Elixir API with configurable settings
- Support for multi-object tracking in real-time
- Rust NIF implementation for high-performance tracking
- Bounding box and detection data structures
- Detection result types with tracking state information
- Configurable thresholds for track initialization, matching, and confidence scoring
