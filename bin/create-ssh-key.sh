#!/usr/bin/env bash

echo_usage() { 
  echo "This script will create a default SSH private and public key. The keys will be"
  echo "places in the ~/.ssh as id_rsa and id_rsa.pub."
  echo
  echo "Usage:"
  echo " $(basename ${BASH_SOURCE[0]}): [-v] subject"
  echo
  echo "Options:"
  echo " -v, --verbose  Verbose output."
} 

subject=
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
      if [ -z "${subject}" ]; then
        subject=${1}
      else
        echo "$(basename ${BASH_SOURCE[0]}): Error: Invalid option: ${1}" >&2
        echo_usage ${0}
        exit 1
      fi
      shift
      ;;
  esac
done

if [ -z ${subject} ]; then
  echo "$(basename ${BASH_SOURCE[0]}): Error: Missing subject parameter" >&2
  echo_usage ${0}
  exit 1
fi

# Create the .ssh directory if it does not exist.
if [ ! -d ~/.ssh ]; then
  [ ${opt_verbose} == yes ] && echo Creating ~/.ssh
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
fi

if [ -f ~/.ssh/id_rsa ]; then
  echo "$(basename ${BASH_SOURCE[0]}): Error: ~/.ssh/id_rsa already exists" >&2
  exit 1
fi

if [ -f ~/.ssh/id_rsa.pub ]; then
  echo "$(basename ${BASH_SOURCE[0]}): Error: ~/.ssh/id_rsa.pub already exists" >&2
  exit 1
fi

user=${USER}
if [ ! -z "${C9_USER}" ]; then
  subject=c9_${subject}
  user=${C9_USER}
fi

ssh-keygen -C id_rsa_${user}_${subject}_$(date +%Y%m%d) -f ~/.ssh/id_rsa -N "" || exit 1
echo "~/.ssh/id_rsa.pub contains:"
cat ~/.ssh/id_rsa.pub

exit 0
