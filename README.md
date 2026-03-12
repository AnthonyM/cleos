# CleOS

A Rust operating system built on the seL4 microkernel.

## Overview

CleOS is a capability-based operating system written in Rust, using seL4 as its microkernel foundation. seL4 provides formally verified isolation guarantees; CleOS builds on that foundation to construct a practical, safe OS environment with Rust's memory safety properties enforced at the userspace level.

## Goals

- **Security by construction** — seL4's capability model enforces least-privilege between all system components
- **Memory safety** — Rust eliminates an entire class of bugs in userspace drivers, servers, and applications
- **Minimal trusted computing base** — keep the kernel small and formally verified; push complexity to isolated userspace components
- **Legibility** — clean, well-documented code that is straightforward to audit and extend

## Architecture

CleOS follows a microkernel architecture:

- **Kernel**: seL4 (C, formally verified)
- **Root task**: Rust bootstrap process that initializes the system and manages initial capabilities
- **System servers**: Drivers, filesystems, and services running as isolated userspace processes
- **Applications**: Unprivileged processes communicating via IPC

## Building

### Prerequisites

- Docker
- QEMU (`brew install qemu` on macOS, only needed for local `make run` outside Docker)

### First-time setup

Build the Docker image containing the seL4 kernel, cross-compiler, and Rust kernel loader. This takes ~10-15 minutes on first run:

```bash
make -C docker build
```

### Start the development container

```bash
make -C docker run
make -C docker exec
```

### Inside the container

```bash
make build   # build kernel + root task + bootable image
make run     # boot on QEMU
make clean   # remove build artifacts
```

### Stopping the container

```bash
make -C docker rm-container
```

## Status

Early bootstrap phase. The build system is established and the root task boots on QEMU (aarch64 virt machine).
