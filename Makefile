APP = app-name
APP_DEV = $(APP)-dev

IMAGE = $(APP)
IMAGE_DEV = $(APP_DEV)

CONTAINER = $(APP)
CONTAINER_DEV = $(APP_DEV)

RUN = docker run -d -p 8080:8080 --name $(CONTAINER) $(IMAGE)
RUN_DEV = docker run \
	-v `pwd`:/app \
	--rm \
	-t \
	-p 8080:8080 \
	--name $(CONTAINER_DEV) \
	$(IMAGE_DEV)

PIP_COMPILE = pip-compile

PYLINT = pylint
PYLINTFLAGS = -rn
PYTHONFILES := $(wildcard **/*.py) $(wildcard *.py)

PYTEST = pytest

PEP8 = pep8
AUTOPEP8 = autopep8

ISORT = isort
ISORTFLAGS = -fss

MYPY = mypy

init:
	( \
		git init .; \
		virtualenv -p python3 .venv; \
		source .venv/bin/activate; \
		pip install -U pip; \
		pip install pip-tools; \
		pip-sync requirements-dev.txt requirements.txt; \
	)

compile-deps:
	$(PIP_COMPILE) requirements.in
	$(PIP_COMPILE) requirements-dev.in

pep8:
	$(PEP8) $(PYTHONFILES)

autopep8:
	$(AUTOPEP8) -a -i $(PYTHONFILES)

pylint:
	$(PYLINT) $(PYLINTFLAGS) $(PYTHONFILES)

pytest:
	$(PYTEST) .

cov:
	$(PYTEST) --cov .

mypy:
	$(MYPY) $(PYTHONFILES) --fast-parser --silent-imports

check: mypy pylint cov pep8

isort:
	$(ISORT) $(ISORTFLAGS) $(PYTHONFILES)

build:
	docker build -t $(IMAGE) .

build-dev:
	docker build -t $(IMAGE_DEV) -f Dockerfile.dev .

run: build
	env DEBUG=1 $(RUN)

stop:
	docker stop $(CONTAINER_DEV)
	docker rm $(CONTAINER_DEV)

run-dev: build-dev
	$(RUN_DEV)

stop-dev:
	docker rm -f $(CONTAINER_DEV)
