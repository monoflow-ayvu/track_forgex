# TrackForgex

## Project Overview

TrackForgex is a **ByteTrack multi-object tracking library for Elixir**, implemented as a Rustler NIF wrapper around the [trackforge](https://github.com/onuralpszr/trackforge) Rust library. It ports the Rust tracking engine to Elixir for use in surveillance, video analytics, and edge AI applications — particularly targeting the **SOPHGO SG2002 RISC-V SoC** platform.

License: MIT | Package registry: [hex.pm](https://hex.pm) | Source: [GitHub](https://github.com/monoflow-ayvu/track_forgex)

---

## 3-Layer Architecture

```
Elixir API Layer (lib/trackers/byte_track.ex)
    ├── ByteTrack.new(settings)
    ├── ByteTrack.update(instance, detections)
    └── BBox / Detection structs (Elixir defstructs + @type)
          │
          ▼  Rustler NIF bridge
Rust NIF Layer (native/track_forgex/src/lib.rs)
    ├── NifStruct<N> / NifUnitEnum type mapping
    ├── ByteTrackInstance (ResourceArc wrapping Mutex<ByteTrack>)
    ├── create_byte_track() / byte_track_update(DirtyCpu)
    └── trackforge::trackers::byte_track::ByteTrack calls
          │
          ▼
Core Engine Layer (trackforge Rust library, forked)
    ├── Rust-based ByteTrack (Kalman filter + ReID similarity)
    └── tracking-by-detection paradigm
```

### Key Design Decisions

- **DirtyCpu scheduling**: Tracking updates run on dirty CPU NIF threads to avoid blocking the BEAM scheduler
- **Precompiled NIF binaries**: Shipped via `rustler_precompiled` from GitHub releases (11 platforms × 2 NIF versions)
- **Fallback build**: Set `TRACK_FORGE_FORCE_BUILD=1` to compile from source instead of downloading binaries
- **Resource lifecycle**: `ByteTrackInstance` is a Rustler `ResourceArc` — NIF drops the instance when the Elixir PID exits (GC'd)
- **Forked trackforge**: Dependencies use a custom fork (`git = "https://github.com/fermuch/trackforge.git")` for bug fixes

### Release Matrix

NIF binaries are compiled for **22 targets** (11 platforms × 2 NIF versions):

| Platform | NIF 2.15 | NIF 2.17 |
|---------|-----------|-----------|
| aarch64-apple-darwin | ✅ | ✅ |
| aarch64-unknown-linux-gnu | ✅ | ✅ |
| aarch64-unknown-linux-musl | ✅ | ✅ |
| arm-unknown-linux-gnueabihf | ✅ | ✅ |
| **riscv64gc-unknown-linux-gnu** | ✅ | ✅ |
| **riscv64gc-unknown-linux-musl** | ✅ | ✅ |
| x86_64-apple-darwin | ✅ | ✅ |
| x86_64-pc-windows-gnu | ✅ | ✅ |
| x86_64-pc-windows-msvc | ✅ | ✅ |
| x86_64-unknown-linux-gnu | ✅ | ✅ |
| x86_64-unknown-linux-musl | ✅ | ✅ |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Main language** | Elixir ~1.18 |
| **Native language** | Rust 2021 edition |
| **Build system** | Mix (Elixir) + Cargo (Rust) |
| **NIF bridge** | Rustler 0.37.2 + RustlerPrecompiled 0.8 |
| **Core dep** | [trackforge](https://github.com/fermuch/trackforge) (custom fork) |
| **Dev tooling** | Credo 1.7, ExDoc, Jason |
| **CI** | GitHub Actions (2 workflows) |
| **Dev env** | Devenv (Nix) + direnv |
| **Devcontainer** | `ghcr.io/cachix/devenv/devcontainer:latest` |
| **Dependency bot** | Renovate (extends `config:recommended`) |

---

## Coding Conventions

### Elixir
- **Formatting**: `mix format` via `.formatter.exs` (inputs: `{mix,.formatter}.exs`, `{config,lib,test}/**/*.{ex,exs}`)
- **Naming**: snake_case functions, PascalCase modules/structs
- **Types**: explicit `@type` declarations on all public structs
- **JSON**: Optional `Jason.Encoder` and `stdlib JSON.Encoder` derived implementations where needed
- **Warnings-as-errors**: `mix compile --warnings-as-errors` enforced in CI

### Rust
- **Edition**: 2021
- **NIF functions**: snake_case (`create_byte_track`, `byte_track_update`)
- **Structs**: `NifStruct<N>` for bidirectional Elixir↔Rust mapping
- **Resource management**: `ResourceArc<ByteTrackInstance>` with internal `Mutex<ByteTrack>` for thread safety

### CI Quality Gates
```bash
mix check --ignore todo
# Runs:
#   1. mix format --check-formatted
#   2. mix deps.unlock --check-unused
#   3. credo suggest --strict --all
```

### Git / Release Patterns
- **Branch strategy**: Single `main` branch, feature branches as needed
- **Commits**: Semantic versioning (`bump version to X.Y.Z`), Renovate PR merges
- **Releases**: Tag-based (v0.1.0 → v0.2.1), `CHANGELOG.md` follows [Keep a Changelog](https://keepachangelog.com/) + SemVer
- **Artifacts**: RustlerPrecompiled Action with `actions/attest-build-provenance@v4` for attestation

---

## Development Commands

```bash
# Enter dev shell
devenv shell

# Standard Mix workflow
mix deps.get
mix compile
mix test                    # Full test suite
mix test --cover            # With coverage
mix check --ignore todo     # Formatting + linting + unused deps
mix docs                    # ExDoc generation

# Rust-side (inside devenv shell)
cd native/track_forgex
cargo build --release
cargo test
```

---

## Testing

- **Framework**: ExUnit
- **3 test files** (202 total lines):
  - `test/byte_track_test.exs` — ByteTrack API (3 describe blocks)
  - `test/native_test.exs` — Direct NIF tests (create_instance, update)
  - `test/track_forgex_test.exs` — Doctest on root module + README examples
- **CI**: Full `mix test` run on every push/PR to `main`

---

## Build & Deployment

### Locally
1. `devenv shell` for reproducible dev environment (Elixir, Erlang, Rust, git, ssh, etc.)
2. `mix deps.get && mix compile` (NIF auto-built from Cargo.toml)

### CI/CD
- **elixir.yml**: Push/PR to `main` + releases → `mix deps.get`, `compile --warnings-as-errors`, `check`, `test`
- **release.yml**: Triggered on `main` pushes (native/ changes only) or tags → builds 22 NIF binaries → uploads to GitHub release

### NIF Fallback
Set `TRACK_FORGE_FORCE_BUILD=1` in the environment to bypass precompiled binary download and always compile from source.

---

## Target Platform: SOPHGO SG2002 (RISC-V SG2002)

TrackForgex primarily targets the **SOPHGO SG2002** SoC — a high-performance, low-power AIoT chip designed for edge surveillance, smart doorbells, and visual intelligence applications.

### Processor Core

| Feature | Specification |
|---------|--------------|
| **Primary CPU** | T-Head XuanTie **C906** RISC-V core @ 1.0 GHz |
| **Co-processor** | T-Head C906 @ 700 MHz (no cache) |
| **ISA** | **RV64GCY + XTheadVector** (non-standard T-Head extension) |
| **Pipeline** | 5-8 stage in-order pipeline |
| **I-Cache** | 32 KB (primary) / 32 KB (co-processor) |
| **D-Cache** | 64 KB (primary) / 32 KB (co-processor) |
| **L2 Cache** | 128 KB (primary CPU only; Co-processor has none) |
| **MMU** | Sv39 virtual addressing |
| **TLB** | Up to 512-entry 4-way set-associative shared TLB |
| **Bus** | AXI4.0 128-bit master interface |

### Vector Unit (XTheadVector)

The C906 includes a **custom vector extension (XTheadVector)**, based on the early **RVV v0.7.1** draft. This is **non-standard** and incompatible with ratified RVV v1.0:

| Feature | Details |
|---------|---------|
| **VLEN** | **128 bits** (fixed) |
| **Registers** | 32 vector registers |
| **Element sizes** | INT8, INT16, INT32, FP16, FP32 (no FP64/double-precision) |
| **LMUL** | 1, 2, 4, 8 (grouping registers) |
| **Key CSRs** | `th.vstart`, `th.vxsat`, `vxrm`, `th.vl`, `th.vtype`, `th.vlenb` (prefixed with `th.`) |
| **Detected via** | `mvendorid = 0x5b7` ("T-Head") + `misa` bit 21 = 'V' + `mimpid = 0` |
| **Vector perf** | Up to ~4 GFLOPs (single core at 1 GHz) |
| **Instruction set** | Overlaps RVV v0.7.1 but has differences in vnsrl/vnsra suffixes, mask mode sizes, no vlm/vsm instructions |
| **Status** | Frozen / stable (extension version 1.0) |

**Critical: The C906 does NOT support FP64 (double-precision)** — only FP16 and FP32. This is a major consideration for floating-point workloads.

### Standard ISA Extensions

| Extension | Description | C906 Support |
|-----------|-------------|--------------|
| **RV64I** | Base integer ISA (64-bit) | ✅ |
| **M** | Multiply/Divide | ✅ |
| **A** | Atomics | ✅ |
| **F** | Single-precision float | ✅ |
| **D** | Double-precision float | ✅ (soft/firmware, limited HW) |
| **C** | Compressed instructions | ✅ |
| **V/XTheadVector** | Vector (non-standard v0.7.1) | ✅ 128-bit |
| **Zifencei** | Fence.i instruction | ✅ |
| **Sv39** | Virtual memory (3-level paging) | ✅ |
| **PMP** | Physical Memory Protection (up to 16 regions) | ✅ |

### SoC Integration

| Component | Specification |
|-----------|--------------|
| **TPU** | 1.0 TOPS @ INT8 (self-developed, high-bandwidth scheduling engine) |
| **NPU** | Same TPU (supports Caffe, PyTorch, TensorFlow Lite, ONNX, MXNet) |
| **VPU/ISP** | H.264/H.265 encoder/decoder (up to 5M@30fps), 3D NR, defogging, lens correction |
| **MCU** | 8051 @ 300 MHz (real-time I/O, replaces external MCU) |
| **DDR** | DDR3 16-bit × 1, max 1866 Mbps, 256 MB (1.35V) |
| **Crypto** | Secure boot, secure update, hardware-encrypted data/computing core, TRNG |
| **IO** | USB 2.0 DRD, 5× UART, 3× SPI, 16× PWM, 6× I2C, 4× ADC, GPIOs |
| **Network** | 10/100M MAC PHY |
| **Package** | QFN 9mm × 9mm × 0.9mm (88 pins, 0.35mm pitch) |
| **Power** | ~500mW (1080p + video encode + AI) |
| **Temp** | 0°C – 70°C |

### Optimization Guidelines for SG2002 / C906

When writing or optimizing code for this platform (particularly in the trackforge Rust layer):

1. **Vector operations**: The C906's XTheadVector (128-bit VLEN) is the biggest optimization opportunity. Trackforge already contains vectorized routines for bounding box operations. Keep them in mind for any new computations (Kalman filter, IoU, cosine similarity).

2. **LMUL strategy**: For vectorizable workloads, **maximize LMUL** (up to 8) when possible — it generally gives the best throughput, though `vcompress.vm` instructions don't scale proportionally at high LMUL values.

3. **No FP64 in vector units**: The hw vector unit handles FP32 best. Avoid double-precision (f64) in performance-critical paths — the C906's FPU handles DP but it's slower than SP on this core.

4. **Element size selection**: Use INT8 and FP16 for maximum vector throughput (4 ops/cycle at e8m8 / e16m8). FP32 is 2 ops/cycle. Avoid 64-bit vectors entirely on this core.

5. **Cache**: With only 32 KB I/D cache per core, prefer data-oriented design to minimize cache misses. The 5-8 stage in-order pipeline has no branch predictor, so avoid unpredictable branches in hot loops — use predication or gather/scatter instead.

6. **Memory bandwidth**: 16-bit DDR3 at 1866 Mbps (~3.7 GB/s theoretical). Minimize cross-boundary allocations and prefer flat, contiguous buffers.

7. **DirtyCpu scheduling**: For NIF calls, always use `DirtyCpu` (already implemented). The SG2002 has no hyperthreading, so DirtyCpu avoids starvation of other BEAM schedulers during heavy tracking compute.

8. **RISC-V cross-compilation**: The SG2002 target is `riscv64gc-unknown-linux-gnu` and `riscv64gc-unknown-linux-musl`. Use cross-compilation toolchains that support XTheadVector (`--march=rv64gcxtheadvector --mabi=lp64d`). GCC 12+ and LLVM 15+ have partial XTheadVector support.

9. **No FP64 vector**: The C906's vector unit does **not** support 64-bit element sizes (SEW=64). If your tracking code uses f64 in vectorized paths, consider downcasting to f32 or f16 for the vector unit and promoting back afterward.

### Debugging SG2002 Issues

- Check `misa` CSR: bit 21 (V) should be set, and `mvendorid` should be `0x5b7` to verify XTheadVector
- XTheadVector detection: `mvendorid == 0x5b7 && (misa & (1 << 21)) && mimpid == 0`
- For LLVM issues: The mainline GCC/LLVM toolchains have limited XTheadVector v0.7.1 support — prefer the T-Head custom toolchain or GCC 12+ with `-march=rv64gcxtheadvector`
- Rust `cfg(target_feature)` — check via `rustc -vV` for available target features on riscv64gc

---

## File Structure

```
track_forgex/
├── lib/
│   ├── track_forgex.ex          # Root module (doctests, README examples)
│   ├── native.ex                # RustlerPrecompiled NIF interface
│   ├── utils.ex                 # BBox & Detection structs
│   └── trackers/
│       ├── byte_track.ex        # ByteTrack public API (new/update)
│       └── byte_track/
│           ├── settings.ex      # ByteTrack.Settings struct
│           └── detection_result.ex  # DetectionResult struct
├── native/track_forgex/
│   ├── Cargo.toml               # Rust crate (cdylib, NIF features)
│   ├── Cargo.lock
│   └── src/lib.rs               # Rust NIF (NifStruct, ResourceArc)
├── priv/native/
│   └── track_forgex.so          # Compiled NIF binary (gitignored)
├── test/
│   ├── test_helper.exs          # ExUnit.start()
│   ├── native_test.exs          # NIF-level tests
│   ├── byte_track_test.exs      # ByteTrack API tests
│   └── track_forgex_test.exs    # Doctests
├── .formatter.exs               # Mix format inputs
├── .github/workflows/
│   ├── elixir.yml               # CI: compile, check, test
│   └── release.yml              # NIF precompiled releases
├── devenv.yaml / devenv.nix     # Nix dev environment
├── mix.exs / mix.lock           # Elixir project config
├── VERSION                      # "0.2.1"
├── LICENSE / README.md / CHANGELOG.md
└── AGENTS.md                    # AI agent instructions (this file)
```

---

## Getting Help

- **Issue tracker**: [GitHub issues](https://github.com/monoflow-ayvu/track_forgex/issues)
- **TrackForge (Rust)**: [fermuch/trackforge](https://github.com/fermuch/trackforge) (custom fork)
- **SG2002 docs**: [sophgo/sophgo-doc](https://github.com/sophgo/sophgo-doc) (TRM v1.02)
- **T-Head Vector spec**: [XuanTie C906](https://www.riscvschool.com/2023/03/09/t-head-xuantie-c906-risc-v/) reference docs
