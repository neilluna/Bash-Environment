#!/usr/bin/env bash

# Keep this script idempotent. It will probably be called multiple times.

if [ "${XDG_CACHE_HOME}" ]; then
	if [ "$(readlink -f ${XDG_CACHE_HOME} | grep ^${HOME})" -a ! -d ${XDG_CACHE_HOME} ]; then
		mkdir -p ${XDG_CACHE_HOME}
	fi
else
	export XDG_CACHE_HOME=${HOME}/.cache
	mkdir -p ${XDG_CACHE_HOME}
fi

if [ "${XDG_CONFIG_HOME}" ]; then
	if [ "$(readlink -f ${XDG_CONFIG_HOME} | grep ^${HOME})" -a ! -d ${XDG_CONFIG_HOME} ]; then
		mkdir -p ${XDG_CONFIG_HOME}
	fi
else
	export XDG_CONFIG_HOME=${HOME}/.config
	mkdir -p ${XDG_CONFIG_HOME}
fi

if [ "${XDG_DATA_HOME}" ]; then
	if [ "$(readlink -f ${XDG_DATA_HOME} | grep ^${HOME})" -a ! -d ${XDG_DATA_HOME} ]; then
		mkdir -p ${XDG_DATA_HOME}
	fi
else
	export XDG_DATA_HOME=${HOME}/.local/share
	mkdir -p ${XDG_DATA_HOME}
fi
