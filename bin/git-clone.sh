#!/usr/bin/env bash

echo_usage() { 
	echo "This script will clone a Git repository, disable autocrlf and filemode, and"
	echo "pull all remote branches."
	echo
	echo "Usage:"
	echo " $(basename ${BASH_SOURCE[0]}): [-v] remote [local]"
	echo
	echo "Options:"
	echo " -v, --verbose  Verbose output."
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

# Using ANSI escape codes for color works, yet tput does not.
# This may be caused by tput not being able to determine the terminal type.
function echo_color()
{
	color=${1}
	message=${2}
	echo -e "${color}${message}${reset}"
}

# Command-line switch variables.
remote=
local=
opt_verbose=no

while [ ${#} -gt 0 ]; do
	case "${1}" in
		-h|--help)
			echo_usage ${0}
			exit 0
			;;
		-v|--verbose)
			opt_verbose=yes
			shift
			;;
		*)
			if [ -z "${remote}" ]; then
				remote=${1}
			elif [ -z "${local}" ]; then
				local=${1}
			else
				echo "$(basename ${BASH_SOURCE[0]}): Error: Invalid option: ${1}" >&2
				echo_usage ${0}
				exit 1
			fi
			shift
			;;
	esac
done

if [ -z "${remote}" ]; then
	echo "$(basename ${BASH_SOURCE[0]}): Error: Missing remote parameter" >&2
	echo_usage ${0}
	exit 1
fi

if [ -z "${local}" ]; then
	local=$(basename -s .git ${remote})
fi

if [ -d ${local} ]; then
	echo "$(basename ${BASH_SOURCE[0]}): Error: Directory \"${local}\" already exists" >&2
	exit 1
fi

# Clone the repo and change to its directory.
[ ${opt_verbose} == yes ] && echo_color ${cyan} "Cloning ${remote} to ${local} ..."
git clone ${remote} ${local} || exit 1
cd ${local} || exit 1

# Fix autocrlf and filemode. Cygwin gets it wrong.
[ ${opt_verbose} == yes ] && echo_color ${cyan} "Fixing autocrlf ..."
git config core.autocrlf false || exit 1
[ ${opt_verbose} == yes ] && echo_color ${cyan} "Fixing filemode ..."
git config core.filemode false || exit 1

# Get the default branch name.
default_branch=$(git remote show origin | grep "HEAD branch" | awk '{print $3}')
[ ${opt_verbose} == yes ] && echo_color ${cyan} "The default branch is ${default_branch}"

# Track all remote branches.
tracking_additional_branches=false
for branch in $(git branch --all | grep '^\s*remotes' | awk '$1!~/HEAD$/' | grep -v "^\s*remotes/origin/${default_branch}"); do
	[ ${opt_verbose} == yes ] && echo_color ${cyan} "Tracking ${branch} as ${branch#remotes/origin/} ..."
	git branch --track ${branch#remotes/origin/} ${branch} || exit 1
	tracking_additional_branches=true
done

if [ ${tracking_additional_branches} == true ] ; then
	[ ${opt_verbose} == yes ] && echo_color ${cyan} "Pulling all tracked branches ..."
	git pull --all || exit 1
	exit 1
fi

exit 0
