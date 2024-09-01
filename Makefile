SHELL = /bin/sh
.SUFFIXES:
.PHONY: help
.DEFAULT_GOAL := help

# Version
VERSION            := 1.27.1-alpine
VERSION_PARTS      := $(subst ., ,$(VERSION))

MAJOR              := $(word 1,$(VERSION_PARTS))
MINOR              := $(word 2,$(VERSION_PARTS))
MICRO              := $(word 3,$(VERSION_PARTS))

CURRENT_VERSION_MICRO := $(MAJOR).$(MINOR).$(MICRO)
CURRENT_VERSION_MINOR := $(MAJOR).$(MINOR)
CURRENT_VERSION_MAJOR := $(MAJOR)

DATE                = $(shell date -u +"%Y-%m-%dT%H:%M:%S")
COMMIT             := $(shell git rev-parse HEAD)
AUTHOR             := $(firstword $(subst @, ,$(shell git show --format="%aE" $(COMMIT))))

# Bats parameters
TEST_FOLDER ?= $(shell pwd)/tests

# Docker parameters
ROOT_FOLDER=$(shell pwd)
NS ?= pfillion
IMAGE_NAME ?= reverse-proxy
CONTAINER_NAME ?= reverse-proxy
CONTAINER_INSTANCE ?= default

help: ## Show the Makefile help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

version: ## Show all versionning infos
	@echo CURRENT_VERSION_MICRO="$(CURRENT_VERSION_MICRO)"
	@echo CURRENT_VERSION_MINOR="$(CURRENT_VERSION_MINOR)"
	@echo CURRENT_VERSION_MAJOR="$(CURRENT_VERSION_MAJOR)"
	@echo DATE="$(DATE)"
	@echo COMMIT="$(COMMIT)"
	@echo AUTHOR="$(AUTHOR)"

docker-test: ## Run docker container tests
	container-structure-test test --image $(NS)/$(IMAGE_NAME):$(VERSION) --config $(TEST_FOLDER)/config.yaml
	
test: docker-test ## Run all tests

build: ## Build the image form Dockerfile
	chmod 755 -R ./rootfs/
	docker build \
		--build-arg DATE=$(DATE) \
		--build-arg CURRENT_VERSION_MICRO=$(CURRENT_VERSION_MICRO) \
		--build-arg COMMIT=$(COMMIT) \
		--build-arg AUTHOR=$(AUTHOR) \
		-t $(NS)/$(IMAGE_NAME):$(CURRENT_VERSION_MICRO) \
		-t $(NS)/$(IMAGE_NAME):$(CURRENT_VERSION_MINOR) \
		-t $(NS)/$(IMAGE_NAME):$(CURRENT_VERSION_MAJOR) \
		-t $(NS)/$(IMAGE_NAME):latest \
		-f Dockerfile .


push: ## Push the image to a registry
ifdef DOCKER_USERNAME
	echo "$(DOCKER_PASSWORD)" | docker login -u "$(DOCKER_USERNAME)" --password-stdin
endif
	docker push $(NS)/$(IMAGE_NAME):$(CURRENT_VERSION_MICRO)
	docker push $(NS)/$(IMAGE_NAME):$(CURRENT_VERSION_MINOR)
	docker push $(NS)/$(IMAGE_NAME):$(CURRENT_VERSION_MAJOR)
	docker push $(NS)/$(IMAGE_NAME):latest
    
shell: ## Run shell command in the container
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(CURRENT_VERSION_MICRO) /bin/sh

run: ## Run shell command in the container
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(CURRENT_VERSION_MICRO)
