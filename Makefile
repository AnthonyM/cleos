BUILD ?= build

build_dir := $(BUILD)

sel4_prefix := $(SEL4_INSTALL_DIR)

loader_artifacts_dir := $(SEL4_INSTALL_DIR)/bin
loader := $(loader_artifacts_dir)/sel4-kernel-loader
loader_cli := $(loader_artifacts_dir)/sel4-kernel-loader-add-payload

app_crate := root-task
app := $(build_dir)/$(app_crate).elf
image := $(build_dir)/image.elf

.PHONY: build
build: $(image)

$(app): $(app).intermediate

.INTERMEDIATE: $(app).intermediate
$(app).intermediate:
	SEL4_PREFIX=$(sel4_prefix) \
		cargo build \
			--target-dir $(build_dir)/target \
			--artifact-dir $(build_dir) \
			-p $(app_crate)

$(image): $(app) $(loader) $(loader_cli)
	$(loader_cli) \
		--loader $(loader) \
		--sel4-prefix $(sel4_prefix) \
		--app $(app) \
		-o $@

qemu_cmd := \
	qemu-system-aarch64 \
		-machine virt,virtualization=on -cpu cortex-a57 -m size=1G \
		-serial mon:stdio \
		-nographic \
		-kernel $(image)

.PHONY: run
run: $(image)
	$(qemu_cmd)

.PHONY: clean
clean:
	rm -rf $(build_dir)
	cargo clean
