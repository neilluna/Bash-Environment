#!/usr/bin/env bash

version=7.0.0

echo_version() { 
	echo "Bash environment installation - Version ${version}"
} 

echo_usage() { 
	echo_version
	echo "This script will install an extensible Bash environment."
	echo
	echo "Usage:"
	echo " $(basename ${BASH_SOURCE[0]}): [options]"
	echo
	echo "Options:"
	echo " -h, --help                 Show this help information."
	echo " --pip-requires-virtualenv  Include PIP_REQUIRE_VIRTUALENV variable."
	echo "                            Implies --python3-virtualenv."
	echo " --pipenv-venv-in-project   Include PIPENV_VENV_IN_PROJECT variable."
	echo "                            Implies --python3-virtualenv."
	echo " --prompt                   Include prompt variable."
	echo " --python3-virtualenv       Include Python3 virtualenv variables."
	echo " -v, --verbose              Verbose output."
	echo " --version                  Show the version."
} 

opt_pip_requires_virtualenv=no
opt_pipenv_venv_in_project=no
opt_prompt=no
opt_python3_virtualenv=no
opt_verbose=no

while [ ${#} -gt 0 ]; do
	case "${1}" in
		-h|--help)
			echo_usage ${0}
			exit 0
			;;
		--pip-requires-virtualenv)
			opt_pip_requires_virtualenv=yes
			opt_python3_virtualenv=yes
			shift
			;;
		--pipenv-venv-in-project)
			opt_pipenv_venv_in_project=yes
			opt_python3_virtualenv=yes
			shift
			;;
		--prompt)
			opt_prompt=yes
			shift
			;;
		--python3-virtualenv)
			opt_python3_virtualenv=yes
			shift
			;;
		-v|--verbose)
			opt_verbose=yes
			shift
			;;
		--version)
			echo_version
			exit 0
			;;
		*)
			echo "$(basename ${BASH_SOURCE[0]}): Error: Invalid option: ${1}" >&2
			echo_usage ${0}
			exit 1
			;;
	esac
done

function copy()
{
	opt_verbose=${1}
	src=${2}
	dst=${3}

	[ ${opt_verbose} == yes ] && echo Installing ${dst} ...
	cp --no-preserve=mode "${src}" "${dst}"
}

# Change to the directory of this script.
cd "$(dirname "${BASH_SOURCE[0]}")"

# Install or update ~/bin.
if [ ! -d ~/bin ]; then
	[ ${opt_verbose} == yes ] && echo Creating ~/bin
	mkdir -p ~/bin
fi
copy ${opt_verbose} bin/create-gitconfig.sh ~/bin/create-gitconfig.sh
copy ${opt_verbose} bin/create-hgrc.sh ~/bin/create-hgrc.sh
copy ${opt_verbose} bin/create-ssh-key.sh ~/bin/create-ssh-key.sh
copy ${opt_verbose} bin/git-clone.sh ~/bin/git-clone.sh
copy ${opt_verbose} bin/source-bashrc.d-scripts.sh ~/bin/source-bashrc.d-scripts.sh
find ~/bin -type f -exec chmod u+x '{}' \;

# Install or update ~/.bashrc.d.
if [ ! -d ~/.bashrc.d ]; then
	[ ${opt_verbose} == yes ] && echo Creating ~/.bashrc.d
	mkdir -p ~/.bashrc.d
fi
[ ! -z "$(uname -s | grep -i cygwin)" ] && copy ${opt_verbose} .bashrc.d/cygwin-vagrant-helper.sh ~/.bashrc.d/cygwin-vagrant-helper.sh
copy ${opt_verbose} .bashrc.d/home-bin.sh ~/.bashrc.d/home-bin.sh
copy ${opt_verbose} .bashrc.d/misc-aliases.sh ~/.bashrc.d/misc-aliases.sh
copy ${opt_verbose} .bashrc.d/misc-vars.sh ~/.bashrc.d/misc-vars.sh
copy ${opt_verbose} .bashrc.d/xdg-dirs-vars.sh ~/.bashrc.d/xdg-dirs-vars.sh
[ ${opt_prompt} == yes ] && copy ${opt_verbose} .bashrc.d/prompt.sh ~/.bashrc.d/prompt.sh
[ ${opt_pip_requires_virtualenv} == yes ] && copy ${opt_verbose} .bashrc.d/pip-require-virtualenv.sh ~/.bashrc.d/pip-require-virtualenv.sh
[ ${opt_pipenv_venv_in_project} == yes ] && copy ${opt_verbose} .bashrc.d/pipenv-venv-in-project.sh ~/.bashrc.d/pipenv-venv-in-project.sh
[ ${opt_python3_virtualenv} == yes ] && copy ${opt_verbose} .bashrc.d/python3-virtualenv.sh ~/.bashrc.d/python3-virtualenv.sh
find ~/.bashrc.d -type f -name '*.sh' -exec chmod u+x '{}' \;

# Text lines that delimit the ~/.bashrc.d script calls in ~/.bashrc.
block_start='# Paraselene Software Bash environment - Start of block'
block_end='# Paraselene Software Bash environment - End of block'
block_warning='# Do not remove or modify this line or any of the lines in this block.'

# Install or replace the hook in ~/.bashrc.
sed -i "/^${block_start}/,/^${block_end}/d" ~/.bashrc
echo "${block_start}" >> ~/.bashrc
echo "${block_warning}" >> ~/.bashrc
cat << 'EOF' >> ~/.bashrc
source "${HOME}/bin/source-bashrc.d-scripts.sh"
EOF
echo "${block_end}" >> ~/.bashrc

exit 0
