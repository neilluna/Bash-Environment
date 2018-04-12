#!/usr/bin/env bash

echo_usage() { 
  echo "This script will clone a Git repository, disable autocrlf and filemode, and"
  echo "fetch and pull all remote branches."
  echo
  echo "Usage:"
  echo " $(basename ${BASH_SOURCE[0]}): [-v] remote [local]"
  echo
  echo "Options:"
  echo " -v, --verbose  Verbose output."
} 

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
[ ${opt_verbose} == yes ] && echo "Cloning ${remote} to ${local} ..."
git clone ${remote} ${local} || exit 1
cd ${local} || exit 1

# Fix autocrlf and filemode. Cygwin gets it wrong.
git config core.autocrlf false || exit 1
git config core.filemode false || exit 1

# Get the default branch name.
def_branch=$(basename $(git symbolic-ref HEAD))
[ ${opt_verbose} == yes ] && echo "The default branch is ${def_branch}"

# Track all remote branches.
for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v remotes/origin/${def_branch}`; do
  [ ${opt_verbose} == yes ] && echo "Tracking ${branch} as ${branch#remotes/origin/} ..."
  git branch --track ${branch#remotes/origin/} ${branch} || exit 1
done

# Fetch and pull all remote branches.
[ ${opt_verbose} == yes ] && echo "Fetching all remote branches ..."
git fetch --all || exit 1
[ ${opt_verbose} == yes ] && echo "Pulling all remote branches ..."
git pull --all || exit 1

exit 0
