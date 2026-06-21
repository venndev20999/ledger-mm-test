# Convenience targets. Everything here runs locally — no cloud account needed.
# Adjust as you see fit; if you change the interface, update the README.

IMAGE ?= ledger-api:dev
CLUSTER ?= takehome

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

.PHONY: test
test: ## Run unit tests locally (needs: pip install pytest flask)
	cd app && python -m pytest -q

.PHONY: build
build: ## Build the application image
	docker build -t $(IMAGE) -f app/Dockerfile .

.PHONY: up
up: ## Run the full stack locally with docker compose
	docker compose up --build

.PHONY: down
down: ## Tear down the docker compose stack
	docker compose down -v

.PHONY: kind-up
kind-up: ## Create a local kind cluster
	kind create cluster --name $(CLUSTER)

.PHONY: kind-down
kind-down: ## Delete the local kind cluster
	kind delete cluster --name $(CLUSTER)

.PHONY: load
load: build ## Load the locally-built image into kind
	kind load docker-image $(IMAGE) --name $(CLUSTER)

.PHONY: deploy
deploy: ## Deploy to the local cluster (wire this to your k8s/ or terraform/)
	@echo "TODO: kubectl apply -f k8s/  OR  terraform -chdir=terraform apply"

.PHONY: ci
ci: ## Run the same checks your pipeline runs, locally
	@echo "TODO: lint, test, build, scan, validate manifests, terraform validate"

.PHONY: clean
clean: down kind-down ## Clean everything up
