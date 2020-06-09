#!/usr/bin/env bash

script_version=1.0.0

script_name=$(basename ${BASH_SOURCE[0]})
script_dir=$(dirname ${BASH_SOURCE[0]})
script_path=${BASH_SOURCE[0]}

function echo_usage()
{ 
	echo "${script_name} - Version ${script_version}"
	echo ""
	echo "This script will source the scripts in the ~/.basrc.d directory."
	echo ""
	echo "Usage: source ${script_name}"
	echo ""
	echo "  -h, --help     Output this help information."
	echo "  -v, --verbose  Verbose output."
	echo "      --version  Output the version."
} 

# ANSI color escape sequences for use in echo_color().
black='\e[30m'
red='\e[31m'
green='\e[32m'
yellow='\e[33m'
blue='\e[34m'
magenta='\e[35m'
cyan='\e[36m'
white='\e[37m'
reset='\e[0m'

# Echo color messages.
# Echoing ANSI escape codes for color works, yet tput does not.
# This may be caused by tput not being able to determine the terminal type.
# Usage: echo_color color message
function echo_color()
{
	color=${1}
	message=${2}
	echo -e "${color}${message}${reset}"
}

# Command-line switch variables.
verbose=no

# NOTE: This requires GNU getopt. On Mac OS X and FreeBSD, you have to install this separately.
ARGS=$(getopt -o hv -l help,verbose,version -n ${script_name} -- "${@}")
if [ ${?} != 0 ]; then
	return 1
fi

# The quotes around "${ARGS}" are necessary.
eval set -- "${ARGS}"

# Parse the command line arguments.
while true; do
	case "${1}" in
		-h | --help)
			echo_usage
			return 0
			;;
		-v | --verbose)
			verbose=yes
			shift
			;;
		--version)
			echo "${script_version}"
			return 0
			;;
		--)
			shift
			break
			;;
	esac
done
if [ ${#} -gt 0 ]; then
	echo "${script_name}: Error: Invalid argument: ${1}" >&2
	echo_usage
	return 1
fi

for script in ${HOME}/.bashrc.d/*.sh; do
	source ${script}
done

return 0
