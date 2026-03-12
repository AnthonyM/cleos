work_root := ..

id := cleos
image_tag := $(id)
container_name := $(id)

uid := $(shell id -u)
gid := $(shell id -g)

rustup_channel = $(shell sed -nr 's,channel = "(.*)",\1,p' $(work_root)/rust-toolchain.toml)

.PHONY: none
none:

.PHONY: build
build:
	docker build \
		--build-arg UID=$(uid) \
		--build-arg GID=$(gid) \
		--build-arg RUSTUP_CHANNEL=$(rustup_channel) \
		-t $(image_tag) .

.PHONY: run
run: build
	docker run -d --name $(container_name) \
		--mount type=bind,src=$(abspath $(work_root)),dst=/work \
		$(image_tag) sleep inf

.PHONY: exec
exec:
	docker exec -it $(container_name) bash

.PHONY: rm-container
rm-container:
	for id in $$(docker ps -aq -f "name=^$(container_name)$$"); do \
		docker rm -f $$id; \
	done
