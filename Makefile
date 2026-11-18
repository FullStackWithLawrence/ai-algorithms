SHELL := /bin/bash
REPO_NAME := ai-algorithms

ifeq ($(OS),Windows_NT)
    PYTHON := python.exe
    ACTIVATE_VENV := venv/Scripts/activate
else
    PYTHON := python3.13
    ACTIVATE_VENV := source venv/bin/activate
endif
PIP := $(PYTHON) -m pip

# scaffold .env from .env.example on first use
ifeq ("$(wildcard .env)","")
    $(shell cp .env.example .env)
endif
include .env

.PHONY: all init clean lint analyze pre-commit pre-commit-init pre-commit-run release \
	check-python python-init python-clean python-requirements \
	help

# Default target executed when no arguments are given to make.
all: help

# initialize local development environment.
init:
	@echo "==============================================================================="
	@echo "Initializing local development environment. This will verify and set up your"
	@echo "Python virtual environment, install all 3rd-party package requirements,"
	@echo "and install the pre-commit hooks. This may take a few minutes..."
	@echo "==============================================================================="
	make check-python							# verify Python 3.13 is installed
	make python-init							# create/replace Python virtual environment and install dependencies
	make pre-commit-init						# install and configure pre-commit
	@echo ""
	@echo "==============================================================================="
	@echo "Initialization complete!"
	@echo ""
	@echo "Run 'source venv/bin/activate' to activate the Python virtual environment."
	@echo "    'make help' to see all available commands."
	@echo "==============================================================================="

clean:
	make python-clean

# ---------------------------------------------------------
# Code management
# ---------------------------------------------------------

lint:
	make pre-commit-run

analyze:
	@echo "==============================================================================="
	@echo "Generating code analysis report using cloc ..."
	@echo "==============================================================================="
	cloc . --exclude-ext=svg,json,zip,csv,yml,yaml --vcs=git

pre-commit:
	make pre-commit-init
	make pre-commit-run

pre-commit-init:
	@echo "==============================================================================="
	@echo "Installing and configuring pre-commit ..."
	@echo "==============================================================================="
	pre-commit install
	pre-commit autoupdate

pre-commit-run:
	@echo "==============================================================================="
	@echo "Running pre-commit hooks on all files ..."
	@echo "==============================================================================="
	pre-commit run --all-files

release:
	@echo "==============================================================================="
	@echo "Forcing a new semantic release on GitHub by creating an empty commit and pushing to the repository ..."
	@echo "==============================================================================="
	git commit -m "fix: force a new release" --allow-empty && git push

# ---------------------------------------------------------
# Python
# ---------------------------------------------------------
check-python:
	@echo ""
	@echo "==============================================================================="
	@echo "Verifying that Python $(PYTHON) is installed ..."
	@echo "==============================================================================="
	@echo ""
	@command -v $(PYTHON) >/dev/null 2>&1 || { \
	echo >&2 "This project requires $(PYTHON) but it's not installed.  Aborting."; \
	echo >&2 "python --version output:"; \
	python --version 2>&1; \
	exit 1; \
}

# venv/ is also the notebooks' Jupyter kernel, "venv (3.13.x)".
python-init:
	@echo "==============================================================================="
	@echo "Initializing Python virtual environment and installing dependencies. This may take a few minutes..."
	@echo "==============================================================================="
	make check-python
	make python-clean && \
	npm install && \
	$(PYTHON) -m venv venv && \
	$(ACTIVATE_VENV) && \
	$(PIP) install --upgrade pip && \
	$(PIP) install setuptools wheel pip-tools && \
	$(PIP) install -r requirements/local.txt

python-clean:
	@echo ""
	@echo "==============================================================================="
	@echo "Cleaning Python virtual environment and __pycache__ directories ..."
	@echo "==============================================================================="
	@echo ""
	rm -rf venv
	find . -path ./node_modules -prune -o -name __pycache__ -type d -exec rm -rf {} +

python-requirements:
	@echo "==============================================================================="
	@echo "Compiling and updating Python dependency files using pip-compile ..."
	@echo "==============================================================================="
	pip install --upgrade setuptools wheel "pip-tools>=7.6.1"
	pip-compile --strip-extras requirements/in/base.in -o requirements/base.txt
	pip-compile --strip-extras requirements/in/local.in -o requirements/local.txt

# ---------------------------------------------------------
# Help
# ---------------------------------------------------------

help:
	@echo '===================================================================='
	@echo 'init                   - Initialize the local development environment'
	@echo 'clean                  - Destroy the Python virtual environment and __pycache__ directories'
	@echo '<************************** Code Management **************************>'
	@echo 'lint                   - Run all pre-commit hooks on all files'
	@echo 'analyze                - Generate code analysis report using cloc'
	@echo 'pre-commit             - Install, configure and run pre-commit hooks'
	@echo 'pre-commit-init        - Install and configure pre-commit'
	@echo 'pre-commit-run         - Run all pre-commit hooks on all files'
	@echo 'release                - Force a new GitHub release'
	@echo '<************************** Python **************************>'
	@echo 'check-python           - Verify Python 3.13 is installed'
	@echo 'python-init            - Create a Python virtual environment and install dependencies'
	@echo 'python-clean           - Destroy the Python virtual environment and remove __pycache__ directories'
	@echo 'python-requirements    - Compile requirements/in/*.in into requirements/*.txt'
	@echo '===================================================================='
