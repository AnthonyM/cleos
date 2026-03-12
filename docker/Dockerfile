FROM debian:bookworm

RUN apt-get update -q && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    # seL4 build dependencies
    gcc-aarch64-linux-gnu \
    python3-dev \
    python3-venv \
    cmake \
    ninja-build \
    device-tree-compiler \
    libxml2-utils \
    # QEMU
    qemu-utils \
    qemu-system-arm \
    qemu-efi-aarch64 \
    ipxe-qemu \
    # bindgen
    libclang-dev \
    # convenience
    bash-completion \
    man \
    sudo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

ARG RUSTUP_CHANNEL

RUN curl -sSf https://sh.rustup.rs | \
        bash -s -- -y --no-modify-path \
            --default-toolchain $RUSTUP_CHANNEL \
            --component rust-src

ENV PATH=/root/.cargo/bin:$PATH

ENV SEL4_INSTALL_DIR=/opt/seL4

# Build seL4 kernel for qemu-arm-virt
RUN git clone --branch 14.0.0 https://github.com/seL4/seL4.git

RUN set -eux; \
    cd seL4; \
    python3 -m venv pyenv; \
    export PATH=$(realpath ./pyenv/bin):$PATH; \
    pip install tools/python-deps; \
    cmake \
        -DCROSS_COMPILER_PREFIX=aarch64-linux-gnu- \
        -DCMAKE_INSTALL_PREFIX=$SEL4_INSTALL_DIR \
        -DKernelPlatform=qemu-arm-virt \
        -DKernelArmHypervisorSupport=ON \
        -DKernelVerificationBuild=OFF \
        -DARM_CPU=cortex-a57 \
        -G Ninja \
        -S . \
        -B build; \
    ninja -C build all; \
    ninja -C build install; \
    rm -rf $(pwd);

# Install sel4-kernel-loader and payload CLI from rust-sel4
RUN set -eux; \
    url="https://github.com/seL4/rust-sel4"; \
    rev="2c9786744900433f37e803c25ab208835a802cf3"; \
    common_args="--git $url --rev $rev --root $SEL4_INSTALL_DIR"; \
    CC_aarch64_unknown_none=aarch64-linux-gnu-gcc \
    SEL4_PREFIX=$SEL4_INSTALL_DIR \
        cargo install \
            -Z build-std=core,compiler_builtins \
            -Z build-std-features=compiler-builtins-mem \
            --target aarch64-unknown-none \
            $common_args \
            sel4-kernel-loader; \
    cargo install \
        $common_args \
        sel4-kernel-loader-add-payload;

# Set up non-root user matching host UID/GID
ARG UID
ARG GID

RUN set -eux; \
    if [ $UID -eq 0 ]; then \
        if [ $GID -ne 0 ]; then \
            echo "error: \$UID == 0 but \$GID != 0" >&2; \
            exit 1; \
        fi; \
    else \
        if getent passwd $UID; then \
            echo "error: \$UID $UID already exists" >&2; \
            exit 1; \
        fi; \
        if ! getent group $GID; then \
            groupadd --gid $GID x; \
        fi; \
        useradd --uid $UID --gid $GID --groups sudo --create-home x; \
    fi;

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $UID

RUN set -eux; \
    if [ $UID -ne 0 ]; then \
        curl -sSf https://sh.rustup.rs | \
            bash -s -- -y --no-modify-path --default-toolchain none; \
    fi;

ENV PATH=/home/x/.cargo/bin:$PATH
ENV SHELL=/bin/bash

WORKDIR /work
