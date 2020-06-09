#!/usr/bin/env bash

# Keep this script idempotent. It will probably be called multiple times.

export PROJECT_HOME=~/projects
export WORKON_HOME=~/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=$(which python3)
export VIRTUALENVWRAPPER_VIRTUALENV=$(which virtualenv)
source $(which virtualenvwrapper.sh)
