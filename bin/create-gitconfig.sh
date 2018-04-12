#!/usr/bin/env bash

echo_usage() { 
  echo "This script will create a default .gitconfig file in the home directory."
  echo
  echo "Usage:"
  echo " $(basename ${BASH_SOURCE[0]}): [-v] name email"
  echo
  echo "Options:"
  echo " -v, --verbose  Verbose output."
} 

name=
email=
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
      if [ -z "${name}" ]; then
        name=${1}
      elif [ -z "${email}" ]; then
        email=${1}
      else
        echo "$(basename ${BASH_SOURCE[0]}): Error: Invalid option: ${1}" >&2
        echo_usage ${0}
        exit 1
      fi
      shift
      ;;
  esac
done

if [ -z "${name}" ]; then
  echo "$(basename ${BASH_SOURCE[0]}): Error: Missing name parameter" >&2
  echo_usage ${0}
  exit 1
fi

if [ -z "${email}" ]; then
  echo "$(basename ${BASH_SOURCE[0]}): Error: Missing email parameter" >&2
  echo_usage ${0}
  exit 1
fi

git config --global user.name "${name}" || exit 1
git config --global user.email ${email} || exit 1
git config --global --bool core.autocrlf false || exit 1
git config --global --bool core.filemode false || exit 1
git config --global credential.helper cache || exit 1
git config --global credential.helper "cache --timeout=3600" || exit 1
git config --global push.default simple || exit 1

exit 0
