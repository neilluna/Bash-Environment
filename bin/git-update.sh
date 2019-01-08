#!/usr/bin/env bash

echo_usage() { 
	echo "This script will update a local Git repository by tracking all remote branches, fetching"
	echo "them, and deleting all local branches that are no longer on the remote."
	echo
	echo "Usage:"
	echo " $(basename ${BASH_SOURCE[0]}): [-v]"
	echo
	echo "Options:"
	echo " -v, --verbose  Verbose output."
} 

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
			echo "$(basename ${BASH_SOURCE[0]}): Error: Invalid option: ${1}" >&2
			echo_usage ${0}
			exit 1
			;;
	esac
done

# Checkout and pull all local branches.
for branch in $(git branch | sed -e 's/^\*/ /' | awk '{print $1}'); do
	[ ${opt_verbose} == yes ] && echo "Checking out and pulling ${branch} ..."
	git checkout ${branch} || exit 1
	git pull || exit 1
done

# Change to the default branch.
def_branch=$(git remote show origin | grep "HEAD branch" | awk '{print $3}')
[ ${opt_verbose} == yes ] && echo "Checking out the default branch, ${def_branch}"
git checkout ${def_branch} || exit 1

# Delete all local branches that are tracking deleted remote branches.
git fetch --prune || exit 1
for branch in $(git branch -vv | grep -v '^\*' | awk '$3~/^\[.*/' | awk '$4~/^gone\]$/{print $1}'); do
	[ ${opt_verbose} == yes ] && echo "Deleting ${branch} ..."
	git branch -d ${branch} || exit 1
done

# Checkout all remote branches that are not tracking local branches.
for branch in $(git branch -r | awk '$1!~/HEAD$/{print $1}'); do
	local_branch=$(git branch -vv | sed -e 's/^\*/ /' | awk '$3~/^\[.*\]/' | awk "\$3==\"[${branch}]\"{print \$1}")
	if [ -z "${local_branch}" ]; then
		[ ${opt_verbose} == yes ] && echo "Checking out ${branch#*/} ..."
		git checkout ${branch#*/} || exit 1
	fi
done

# Change to the default branch.
def_branch=$(git remote show origin | grep "HEAD branch" | awk '{print $3}')
[ ${opt_verbose} == yes ] && echo "Checking out the default branch, ${def_branch}"
git checkout ${def_branch} || exit 1

exit 0
