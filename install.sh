#!/usr/bin/env bash

script_version=8.0.0

script_name=$(basename ${BASH_SOURCE[0]})
script_dir=$(dirname ${BASH_SOURCE[0]})
script_path=${BASH_SOURCE[0]}

function echo_usage()
{ 
	echo "${script_name} - Version ${script_version}"
	echo ""
	echo "This script will clone a Git repository and set autocrlf and filemode to false."
	echo ""
	echo "Usage: ${script_name}: [options]"
	echo ""
	echo "  -h, --help                     Output this help information."
	echo "      --pip-requires-virtualenv  Include PIP_REQUIRE_VIRTUALENV variable."
	echo "                                 Implies --python3-virtualenv."
	echo "      --pipenv-venv-in-project   Include PIPENV_VENV_IN_PROJECT variable."
	echo "                                 Implies --python3-virtualenv."
	echo "      --prompt                   Include prompt variable."
	echo "      --python3-virtualenv       Include Python3 virtualenv variables."
	echo "  -v, --verbose                  Verbose output."
	echo "      --version                  Output the version."
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
pip_requires_virtualenv=no
pipenv_venv_in_project=no
prompt=no
python3_virtualenv=no
verbose=no

# NOTE: This requires GNU getopt. On Mac OS X and FreeBSD, you have to install this separately.
getopt_long_args="help,pip-requires-virtualenv,pipenv-venv-in-project,prompt,python3-virtualenv,verbose,version"
ARGS=$(getopt -o hv -l ${getopt_long_args} -n ${script_name} -- "${@}")
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
		--pip-requires-virtualenv)
			pip_requires_virtualenv=yes
			python3_virtualenv=yes
			shift
			;;
		--pipenv-venv-in-project)
			pipenv_venv_in_project=yes
			python3_virtualenv=yes
			shift
			;;
		--prompt)
			prompt=yes
			shift
			;;
		--python3-virtualenv)
			python3_virtualenv=yes
			shift
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
if [ ${#} -gt 0 ]; then
	echo "${script_name}: Error: Invalid argument: ${1}" >&2
	echo_usage
	exit 1
fi

# Copy a file without inheriting the mode.
# Usage: echo_color verbose src_file dst_file
function copy()
{
	verbose=${1}
	src=${2}
	dst=${3}
	[ ${verbose} == yes ] && echo "Installing ${dst} ..."
	cp --no-preserve=mode "${src}" "${dst}"
}

# Change to the directory of this script.
cd ${script_dir}

# Install or update ~/bin.
if [ ! -d ~/bin ]; then
	[ ${verbose} == yes ] && echo "Creating ~/bin ..."
	mkdir -p ~/bin
fi
copy ${verbose} bin/create-gitconfig.sh ~/bin/create-gitconfig.sh
copy ${verbose} bin/create-hgrc.sh ~/bin/create-hgrc.sh
copy ${verbose} bin/create-ssh-key.sh ~/bin/create-ssh-key.sh
copy ${verbose} bin/git-clone.sh ~/bin/git-clone.sh
copy ${verbose} bin/source-bashrc.d-scripts.sh ~/bin/source-bashrc.d-scripts.sh
find ~/bin -type f -exec chmod u+x '{}' \;

# Install or update ~/.bashrc.d.
if [ ! -d ~/.bashrc.d ]; then
	[ ${verbose} == yes ] && echo "Creating ~/.bashrc.d ..."
	mkdir -p ~/.bashrc.d
fi
[ ! -z "$(uname -s | grep -i cygwin)" ] && copy ${verbose} .bashrc.d/cygwin-vagrant-helper.sh ~/.bashrc.d/cygwin-vagrant-helper.sh
copy ${verbose} .bashrc.d/home-bin.sh ~/.bashrc.d/home-bin.sh
copy ${verbose} .bashrc.d/misc-aliases.sh ~/.bashrc.d/misc-aliases.sh
copy ${verbose} .bashrc.d/misc-vars.sh ~/.bashrc.d/misc-vars.sh
# copy ${verbose} .bashrc.d/xdg-dirs-vars.sh ~/.bashrc.d/xdg-dirs-vars.sh
[ ${prompt} == yes ] && copy ${verbose} .bashrc.d/prompt.sh ~/.bashrc.d/prompt.sh
[ ${pip_requires_virtualenv} == yes ] && copy ${verbose} .bashrc.d/pip-require-virtualenv.sh ~/.bashrc.d/pip-require-virtualenv.sh
[ ${pipenv_venv_in_project} == yes ] && copy ${verbose} .bashrc.d/pipenv-venv-in-project.sh ~/.bashrc.d/pipenv-venv-in-project.sh
[ ${python3_virtualenv} == yes ] && copy ${verbose} .bashrc.d/python3-virtualenv.sh ~/.bashrc.d/python3-virtualenv.sh
find ~/.bashrc.d -type f -name '*.sh' -exec chmod u+x '{}' \;

# Text lines that delimit the hook in ~/.bashrc.
block_start='# bash-environment - Start of block'
block_end='# bash-environment - End of block'
block_warning='# Do not remove or modify any of the lines in this block.'

# Install or replace the hook in ~/.bashrc.
sed -i "/^${block_start}/,/^${block_end}/d" ~/.bashrc
echo "${block_start}" >> ~/.bashrc
echo "${block_warning}" >> ~/.bashrc
cat << 'EOF' >> ~/.bashrc
source ${HOME}/bin/source-bashrc.d-scripts.sh
EOF
echo "${block_end}" >> ~/.bashrc

exit 0
