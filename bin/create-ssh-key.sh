#!/usr/bin/env bash

echo_usage() { 
	echo "This script will create an SSH private and public key. The keys will be"
	echo "placed in the current directory, and named the same as the key comment."
	echo
	echo "Usage:"
	echo " $(basename ${BASH_SOURCE[0]}): [-v] [subject]"
	echo
	echo " The key comment and key file basename will be created as follows:"
	echo "   id_rsa_subject"
	echo " If the subject parameter is not specified, it will default to:"
	echo "   user_hostname_yymmdd"
	echo " where yymmdd is the current date."
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

user=${USER}
if [ ! -z "${C9_USER}" ]; then
	user=${C9_USER}
	[ ${opt_verbose} == yes ] && echo Cloud9 detected. The user will be ${user}.
fi

if [ -z "${subject}" ]; then
	subject=${user}_$(hostname)_$(date +%Y%m%d)
	[ ${opt_verbose} == yes ] && echo No subject given. The subject will be ${subject}.
fi

comment=id_rsa_${subject}
key_file=${comment}

if [ ${opt_verbose} == yes ]; then
	echo The key comment will be ${comment}.
fi

# Create the .ssh directory if it does not exist.
if [ ! -d ~/.ssh ]; then
	[ ${opt_verbose} == yes ] && echo Creating ~/.ssh
	mkdir -p ~/.ssh
	chmod 700 ~/.ssh
fi

if [ -f ${key_file} ]; then
	echo "$(basename ${BASH_SOURCE[0]}): Error: ${key_file} already exists." >&2
	exit 1
fi

if [ -f ${key_file}.pub ]; then
	echo "$(basename ${BASH_SOURCE[0]}): Error: ${key_file}.pub already exists." >&2
	exit 1
fi

ssh-keygen -C ${comment} -f ${key_file} -N "" || exit 1
if [ ${opt_verbose} == yes ]; then
	echo "${key_file}.pub contains:"
	cat ${key_file}.pub
fi

exit 0
