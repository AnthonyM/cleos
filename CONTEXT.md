# CleOS — LLM Context File

This file is for AI assistants working on this project. It tracks the current state of CleOS, key architectural decisions, component status, and open questions. Update it as components are built and decisions are made.

## Project Summary

CleOS is a Rust OS built on the seL4 microkernel. seL4 runs in kernel space (C, formally verified). All OS services run as isolated Rust processes in userspace, communicating via seL4 IPC and capability passing.

## Repository Layout

```
cleos/
  Makefile                      # top-level: build, clean, run (used inside Docker)
  rust-toolchain.toml           # pins nightly-2025-10-20
  Cargo.toml                    # workspace root
  .cargo/config.toml            # custom target (aarch64-sel4), build-std
  support/targets/
    aarch64-sel4.json           # custom rustc target spec for seL4
  docker/
    Dockerfile                  # builds seL4 kernel + sel4-kernel-loader
    Makefile                    # container lifecycle (build, run, exec, rm-container)
  crates/
    root-task/                  # the seL4 root task (entry point of the OS)
      Cargo.toml
      src/main.rs
```

## Components

| Component | Status | Description |
|---|---|---|
| Build system | Done | Make + Cargo + Docker; seL4 built in container |
| Root task | Minimal | Prints hello, suspends. Entry point for future OS services |
| System servers | Not started | Drivers, filesystem, etc. |
| IPC framework | Not started | Capability-based message passing |

## Key Decisions

- **Architecture**: aarch64, targeting QEMU virt machine for development
- **Build isolation**: seL4 kernel and kernel loader are built inside Docker. Day-to-day Rust development uses Make + Cargo inside the container. CMake only runs during `docker build`.
- **rust-sel4 ecosystem**: Using the `sel4` and `sel4-root-task` crates from github.com/seL4/rust-sel4 rather than raw seL4 C bindings. The `sel4-kernel-loader` (Rust) replaces the traditional C elfloader.
- **seL4 version**: 14.0.0
- **rust-sel4 revision**: `2c9786744900433f37e803c25ab208835a802cf3`
- **Nightly toolchain**: `nightly-2025-10-20` (known-good with rust-sel4)

## In-Progress Work

> None currently.

## Open Questions

- Target architecture for real hardware (aarch64 dev board? RISC-V?)
- IPC abstraction design for system servers
- Root task responsibility boundaries — how much does it manage vs. delegate?

## Build System

The build has three layers:

1. **Docker** (`docker/Dockerfile`): Builds the seL4 kernel with CMake/Ninja for `qemu-arm-virt` platform, installs it to `/opt/seL4`. Also installs `sel4-kernel-loader` and `sel4-kernel-loader-add-payload` from rust-sel4 via `cargo install`.

2. **Cargo** (`.cargo/config.toml`): Cross-compiles Rust crates for the custom `aarch64-sel4` target with `build-std` (rebuilds core/alloc from source). The `SEL4_PREFIX` env var points build scripts at the installed seL4 headers and config.

3. **Make** (`Makefile`): Orchestrates cargo build, then uses `sel4-kernel-loader-add-payload` to combine the kernel loader + seL4 kernel + root task ELF into a single bootable `image.elf`. QEMU loads this image directly via `-kernel`.
