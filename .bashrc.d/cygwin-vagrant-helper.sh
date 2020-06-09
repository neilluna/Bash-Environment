#!/usr/bin/env bash

# Keep this script idempotent. It will probably be called multiple times.

# Tell Vagrant to use the system SSH, not its embedded SSH.
export VAGRANT_PREFER_SYSTEM_BIN=1
