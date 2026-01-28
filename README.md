# TrackForgex

[![Elixir CI](https://github.com/monoflow-ayvu/track_forgex/actions/workflows/elixir.yml/badge.svg)](https://github.com/monoflow-ayvu/track_forgex/actions/workflows/elixir.yml)
[![docs](https://img.shields.io/badge/docs-latest-brightgreen.svg)](https://hexdocs.pm/track_forgex)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A port of [trackforge](https://docs.rs/trackforge/latest/trackforge/) from Rust to Elixir using Rustler. An open-source multi-object tracking library for real-time video analysis, currently implementing the ByteTrack algorithm.

## Features

- **Port of trackforge**: Direct port of the Rust tracking library to Elixir, maintaining feature parity and performance characteristics
- **ByteTrack implementation**: Currently implements only the ByteTrack algorithm
- **High performance**: Rust-based NIF implementation ensuring low overhead and fast execution
- **Elixir-friendly API**: Clean, idiomatic Elixir interface with comprehensive types and documentation
- **Flexible configuration**: Configurable thresholds for track initialization, matching, and confidence scoring
- **Extensible architecture**: Designed to, in the future, support additional trackers from trackforge (e.g., DeepSORT, FairMOT)

## Installation

Add `track_forgex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:track_forgex, "~> 0.1.0"}
  ]
end
```

After installing, you need to compile the NIF:

```bash
mix deps.compile
```

## Quick Start

### Basic Usage

```elixir
iex> # Create a ByteTracker instance with custom settings
iex> settings = %TrackForgex.Trackers.ByteTrack.Settings{
...>   track_thresh: 0.5,
...>   track_buffer: 30,
...>   match_thresh: 0.8,
...>   det_thresh: 0.6
...> }
iex> tracker = TrackForgex.Trackers.ByteTrack.new(settings)
iex> # Process detections from a detector
iex> detections = [
...>   %TrackForgex.Utils.Detection{
...>     bbox: %TrackForgex.Utils.BBox{x: 10.0, y: 20.0, w: 100.0, h: 50.0},
...>     score: 0.9,
...>     class_id: 0
...>   },
...>   %TrackForgex.Utils.Detection{
...>     bbox: %TrackForgex.Utils.BBox{x: 150.0, y: 30.0, w: 80.0, h: 60.0},
...>     score: 0.85,
...>     class_id: 0
...>   }
...> ]
iex> # Update tracker and get results
iex> results = TrackForgex.Trackers.ByteTrack.update(tracker, detections)
iex> # Results contain track IDs, states, and positions
iex> results
[
  %TrackForgex.Trackers.ByteTrack.DetectionResult{
    bbox: %TrackForgex.Utils.BBox{x: 10.0, y: 20.0, w: 100.0, h: 50.0},
    score: 0.8999999761581421,
    class_id: 0,
    track_id: 1,
    state: :tracked,
    is_activated: true,
    frame_id: 1,
    start_frame: 1,
    tracklet_len: 0
  },
  %TrackForgex.Trackers.ByteTrack.DetectionResult{
    bbox: %TrackForgex.Utils.BBox{x: 150.0, y: 30.0, w: 80.0, h: 60.0},
    score: 0.8500000238418579,
    class_id: 0,
    track_id: 2,
    state: :tracked,
    is_activated: true,
    frame_id: 1,
    start_frame: 1,
    tracklet_len: 0
  }
]
```

### Configuration

The `Settings` struct allows you to tune the tracking behavior:

```elixir
settings = %TrackForgex.Trackers.ByteTrack.Settings{
  track_thresh: 0.5,      # Threshold for high-confidence detections
  track_buffer: 30,       # Frames to keep a lost track alive
  match_thresh: 0.8,      # IoU threshold for matching
  det_thresh: 0.6         # Detection threshold for new tracks
}
```

### Detection States

Each detection result includes the current tracking state:

- `:new` - New track that hasn't been confirmed yet
- `:tracked` - Confirmed track being actively tracked
- `:lost` - Track that has been lost but preserved
- `:removed` - Track that has been removed

## Development

### Prerequisites

- Elixir 1.18+
- Rust stable
- [Devenv](https://devenv.sh) (optional, for reproducible environments)

### Setup

```bash
# Install dependencies
mix deps.get

# Compile the NIF
mix deps.compile

# Run tests
mix test

# Run code quality checks
mix check
```

### Project Structure

```
track_forgex/
├── lib/
│   ├── track_forgex.ex         # Main module with common utilities
│   ├── native.ex               # NIF interface (Rustler) for trackforge bindings
│   ├── utils.ex                # BBox and Detection structs
│   └── trackers/
│       ├── byte_track.ex       # ByteTrack implementation (currently available)
│       └── [other_trackers]    # Additional trackers from trackforge (future)
├── native/
│   └── track_forgex/
│       └── src/
│           └── lib.rs          # Rust NIF implementation wrapping trackforge
├── test/
│   └── test_helper.exs
├── mix.exs
└── README.md
```

### Architecture

TrackForgex is a thin Elixir wrapper around the [trackforge](https://github.com/onuralpszr/trackforge/) Rust library. The architecture follows the Rustler pattern:

1. **Native Module** (`lib/native.ex`): Defines the Elixir-side NIF interface that marshals data between Elixir and Rust
2. **Rust Layer** (`native/track_forgex/src/lib.rs`): Implements the trackforge library functions, converting between Rust and Elixir types
3. **Elixir API** (`lib/trackers/byte_track.ex`): Provides a clean, idiomatic Elixir interface to the tracker functionality
4. **Data Models** (`lib/utils.ex`): Defines Elixir structs for bounding boxes, detections, and tracker results

This design allows for maximum performance (via Rust) while maintaining the benefits of Elixir's Ecosystem.

### Rust Development

For Rust-specific development:

```bash
cd native/track_forgex
cargo build
```

## License

MIT License - see LICENSE file for details

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## Contributing

Contributions are welcome! Please ensure all tests pass before submitting a pull request.

```bash
# Format code
mix format

# Run checks
mix check

# Run tests with coverage
mix test --cover
```

## Acknowledgments

- **[trackforge](https://github.com/onuralpszr/trackforge/)** - The Rust multi-object tracking library that TrackForgex is based on
- **ByteTrack algorithm** from [ByteTrack: High Performance Multi-Object Tracking by Associating Every Detection Box](https://arxiv.org/abs/2211.04563)
- **Rustler** for seamless Elixir-Rust interop
- The Elixir and Rust communities for excellent tooling and support
