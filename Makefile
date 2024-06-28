#!make

CTR_REGISTRY ?= flomesh
CTR_TAG      ?= latest

DOCKER_BUILDX_PLATFORM ?= linux/amd64
DOCKER_BUILDX_OUTPUT ?= type=registry

DOCKER_ZTM_VERSION = v0.0.4

.PHONY: buildx-context
buildx-context:
	@if ! docker buildx ls | grep -q "^fsm "; then docker buildx create --name fsm --driver-opt network=host; fi

.PHONY: docker-build-fsm-ztm
docker-build-fsm-ztm:
	docker buildx build --builder fsm --platform=$(DOCKER_BUILDX_PLATFORM) -o $(DOCKER_BUILDX_OUTPUT) -t $(CTR_REGISTRY)/fsm-ztm:$(CTR_TAG) -f dockerfiles/Dockerfile.fsm-ztm --build-arg ZTM_VERSION=$(DOCKER_ZTM_VERSION) .

FSM_TARGETS = fsm-ztm

DOCKER_FSM_TARGETS = $(addprefix docker-build-, $(FSM_TARGETS))

.PHONY: docker-build-fsm
docker-build-fsm: $(DOCKER_FSM_TARGETS)

.PHONY: docker-build-cross-fsm docker-build-cross
docker-build-cross-fsm: DOCKER_BUILDX_PLATFORM=linux/amd64
docker-build-cross-fsm: docker-build-fsm

docker-build-cross: docker-build-cross-fsm