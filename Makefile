# BeeBox DevOps Assignment - single entry point.
# Usage: make help

SHELL := /bin/bash
TF_DIR := terraform
ANSIBLE_DIR := ansible

# Load .env if present so LB_PORT / DB_* / DOCKER_HOST are available to recipes.
ifneq (,$(wildcard .env))
include .env
export
endif

LB_PORT ?= 8080
LB_HOSTNAME ?= ucpe.swisscom.com

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

.PHONY: hosts
hosts: ## Add 127.0.0.1 ucpe.swisscom.com to /etc/hosts (asks for sudo)
	./scripts/setup-hosts.sh

.PHONY: up
up: ## Provision infrastructure with Terraform (network + containers)
	cd $(TF_DIR) && terraform init -input=false && terraform apply -auto-approve

.PHONY: configure
configure: ## Configure all servers with Ansible
	cd $(ANSIBLE_DIR) && ansible-galaxy collection install -r requirements.yml \
		&& ansible-playbook -i inventory.ini playbook.yml

.PHONY: test
test: ## Run smoke test against the load balancer (asserts JSON + round-robin)
	LB_PORT=$(LB_PORT) LB_HOSTNAME=$(LB_HOSTNAME) ./scripts/smoke-test.sh

.PHONY: all
all: up configure test ## Full pipeline: provision -> configure -> test

.PHONY: down
down: ## Tear down all infrastructure
	cd $(TF_DIR) && terraform destroy -auto-approve

.PHONY: lint
lint: ## Lint/validate IaC, Ansible, YAML, Python
	cd $(TF_DIR) && terraform fmt -check -recursive && terraform init -backend=false -input=false && terraform validate
	yamllint -c .yamllint . || true
	cd $(ANSIBLE_DIR) && ansible-lint || true
	flake8 app || true

.PHONY: clean
clean: down ## Alias for down
