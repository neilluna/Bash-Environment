#!/usr/bin/env bash

# Keep this script idempotent. It will probably be called multiple times.

if [ -z $(echo ":${PATH}:" | egrep ".*:(${HOME}|~)/bin:.*") ]; then
	PATH="${HOME}/bin:${PATH}"
fi
