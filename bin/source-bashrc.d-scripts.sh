#!/usr/bin/env bash

echo_usage() { 
	echo "This script will source the scripts in the ~/.basrc.d directory."
	echo
	echo "Usage:"
	echo " source $(basename ${BASH_SOURCE[0]})"
} 

while [ ${#} -gt 0 ]; do
	case "${1}" in
		-h|--help)
			echo_usage ${0}
			exit 0
			;;
		*)
			echo "$(basename ${BASH_SOURCE[0]}): Error: Invalid option: ${1}" >&2
			echo_usage ${0}
			exit 1
			;;
	esac
done

for script in "${HOME}"/.bashrc.d/*.sh; do
	[ -f "${script}" ] && source "${script}"
done
