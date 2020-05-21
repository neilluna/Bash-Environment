#!/usr/bin/env bash

script_version=1.0.0

script_name=$(basename ${BASH_SOURCE[0]})
script_dir=$(dirname ${BASH_SOURCE[0]})
script_path=${BASH_SOURCE[0]}

function echo_usage()
{ 
	echo "${script_name} - Version ${script_version}"
	echo ""
	echo "This script will clone a Git repository and set autocrlf and filemode to false."
	echo ""
	echo "Usage: ${script_name} [-v] remote [local]"
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
remote=
local=
verbose=no

# NOTE: This requires GNU getopt. On Mac OS X and FreeBSD, you have to install this separately.
ARGS=$(getopt -o hv -l help,verbose,version -n ${script_name} -- "${@}")
if [ ${?} != 0 ]; then
	exit 1
fi

# The quotes around "${ARGS}" are necessary.
eval set -- "${ARGS}"

# Parse the command line arguments.
while true; do
	case "${1}" in
		-h | --help)
			echo_usage
			exit 0
			;;
		-v | --verbose)
			verbose=yes
			shift
			;;
		--version)
			echo "${script_version}"
			exit 0
			;;
		--)
			shift
			break
			;;
	esac
done
while [ ${#} -gt 0 ]; do
	if [ -z "${remote}" ]; then
		remote=${1}
	elif [ -z "${local}" ]; then
		local=${1}
	else
		echo "${script_name}: Error: Invalid argument: ${1}" >&2
		echo_usage
		exit 1
	fi
	shift
done
if [ -z "${remote}" ]; then
	echo "${script_name}: Error: Missing remote parameter." >&2
	echo_usage ${0}
	exit 1
fi
if [ -z "${local}" ]; then
	local=$(basename -s .git ${remote})
fi
if [ -d ${local} ]; then
	echo "${script_name}: Error: Directory '${local}' already exists." >&2
	exit 1
fi

# Clone the repo and change to its directory.
[ ${verbose} == yes ] && echo_color ${cyan} "Cloning ${remote} to ${local} ..."
git clone ${remote} ${local} || exit 1
cd ${local} || exit 1

# Fix autocrlf and filemode.
[ ${verbose} == yes ] && echo_color ${cyan} "Setting autocrlf to false ..."
git config core.autocrlf false || exit 1
[ ${verbose} == yes ] && echo_color ${cyan} "Setting filemode to false ..."
git config core.filemode false || exit 1

# Get the default branch name.
default_branch=$(git remote show origin | grep "HEAD branch" | awk '{print $3}')
[ ${verbose} == yes ] && echo_color ${cyan} "The default branch is '${default_branch}'"

exit 0
