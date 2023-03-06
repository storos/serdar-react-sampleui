MODULE = $(shell go list -m)
VERSION ?= $(shell git describe --tags --always --dirty --match=v* 2> /dev/null || echo "1.0.0")
LDFLAGS := -ldflags "-X main.Version=${VERSION}"
CMD_NAME=serdar-react-sampleui
GCP_PROJECT_NAME=bubbly-yeti-377212
DOCKER_TAG_VERSION=3

.PHONY: default
default: help

.PHONY: help
help: ## help information about make commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build:  ## build the cli binary
	npm install

.PHONY: run
run: ## run the cli
	npm run

.PHONY: build-docker
docker-build: ## build the cli as a docker image
	docker build --platform=linux/amd64 -f Dockerfile -t $(CMD_NAME):$(DOCKER_TAG_VERSION) .

.PHONY: build-tag
docker-tag: ## build the cli as a docker image tag
	docker tag $(CMD_NAME):$(DOCKER_TAG_VERSION) gcr.io/$(GCP_PROJECT_NAME)/$(CMD_NAME):$(DOCKER_TAG_VERSION)

.PHONY: build-push
docker-push: ## build the cli as a docker image tag
	docker push gcr.io/$(GCP_PROJECT_NAME)/$(CMD_NAME):$(DOCKER_TAG_VERSION)

.PHONY: kube-install
kube-install: ## install version into select kubernetes context
	kubectl apply -f ./deployments/

.PHONY: dev-env-start
dev-env-start: ## build the cli as a docker image
	docker rm $(CMD_NAME) -f

	docker run -it -p 8080:80 --name $(CMD_NAME) $(CMD_NAME):$(DOCKER_TAG_VERSION)

.PHONY: version
version: ## display the version of the cli
	@echo $(VERSION)

.PHONY: dev-env-stop
dev-env-stop: ## stop the services
	docker stop $(CMD_NAME)