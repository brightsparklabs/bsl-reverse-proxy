##
 # Makefile
 # ______________________________________________________________________________
 #
 # Created by brightSPARK Labs
 # www.brightsparklabs.com
 ##

# Warn whenever make sees a reference to an undefined variable.
MAKEFLAGS += --warn-undefined-variables
# Disable implicit rules as they were not designed for python.
MAKEFLAGS += --no-builtin-rules

VENV_NAME?=.venv
VENV_ACTIVATE=. $(VENV_NAME)/bin/activate
PYTHON=${VENV_NAME}/bin/python
APP_VERSION=$(shell git describe --always --dirty)
PRECOMMIT_FILE=.pre-commit-config.yaml

# The below `awk` is a simple variation for self-documenting Makefiles. See:
# https://ricardoanderegg.com/posts/makefile-python-project-tricks/
#
# Basically this allows task documentation to be appended to the task name
# with two hashes and it will be picked up in help output.
.DEFAULT: help
.PHONY: help
help: ## Display this help section
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z\$$/]+.*:.*?##\s/ {printf "\033[36m%-38s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: venv
venv: $(VENV_NAME)/bin/activate ## Creates and initialises python virtual env
$(VENV_NAME)/bin/activate: requirements.txt requirements-dev.txt
	test -d ${VENV_NAME} || python -m venv ${VENV_NAME}
	${PYTHON} -m pip install -U pip
	${PYTHON} -m pip install -r requirements.txt -r requirements-dev.txt
	${PYTHON} ${VENV_NAME}/bin/pre-commit install --config ${PRECOMMIT_FILE}
	touch ${VENV_NAME}/bin/activate

.PHONY: test
test: venv lint ## Run all tests
	${PYTHON} -m pytest

.PHONY: lint
lint: venv ## Lint all code
	${PYTHON} -m ruff check .

.PHONY: format
format: venv ## Format all code
	${PYTHON} -m ruff format .

.PHONY: docker
docker: ## Build docker image
	docker build --build-arg APP_VERSION=${APP_VERSION} \
		-t docker.brightsparklabs.com/brightsparklabs/reverse-proxy:${APP_VERSION} \
		-t docker.brightsparklabs.com/brightsparklabs/reverse-proxy:latest .

.PHONY: docker-publish
docker-publish: docker ## Publish the the docker image
	docker push docker.brightsparklabs.com/brightsparklabs/reverse-proxy:${APP_VERSION}

.PHONY: precommit
precommit: venv ## Run precommit hooks.
	$(VENV_NAME)/bin/pre-commit run -c ${PRECOMMIT_FILE}