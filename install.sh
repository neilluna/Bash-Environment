#!/usr/bin/env bash

echo_usage() { 
  echo "This script will install the various files for my Bash environment."
  echo
  echo "Usage:"
  echo " $(basename ${BASH_SOURCE[0]}): [options]"
  echo
  echo "Options:"
  echo " --pip-requires-virtualenv  Include PIP_REQUIRE_VIRTUALENV variable."
  echo "                            Implies --python3-virtualenv."
  echo " --prompt                   Include prompt variable."
  echo " --python3-virtualenv       Include Python3 virtualenv variables."
  echo " -h, --help                 Show this help information."
  echo " -v, --verbose              Verbose output."
} 

opt_pip_requires_virtualenv=no
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
    *)
      echo "$(basename ${BASH_SOURCE[0]}): Error: Invalid option: ${1}" >&2
      echo_usage ${0}
      exit 1
      ;;
  esac
done

cd "$(dirname "${BASH_SOURCE[0]}")"

# Create a temporary copy script.
tmp_cp_script=$(mktemp --tmpdir tmp_cp_XXXXXXXXXX.sh)
cat << 'EOF1' > ${tmp_cp_script}
#!/usr/bin/env bash

# This script is used in order to avoid using multiple '{}' arguments in the '-exec' clause of the calling 'find'.
# By 'find' standard, behavior using multiple '{}' arguments in the '-exec' clause is unspecified.

opt_verbose=${1}
src=${2}
dst=${3}

[ ${opt_verbose} == yes ] && echo Installing ${dst}
cp --no-preserve=mode "${src}" "${dst}"
EOF1
chmod u+x ${tmp_cp_script}

# Find the correct profile or login script.
profile_script=~/.bash_profile
if [ -f ~/.bash_profile ]; then
  profile_script=~/.bash_profile
elif [ -f ~/.bash_login ]; then
  profile_script=~/.bash_login
elif [ -f ~/.profile ]; then
  profile_script=~/.profile
fi

# Text lines that delimit the ~/.bash_profile.d and ~/.bashrc.d script calls in ~/.bash_profile and ~/.bashrc.
block_start='# Shell environment - Start of block'
block_end='# Shell environment - End of block'
block_warning='Do not remove or modify this line or any of the lines in this block.'

# Install or update ~/.bash_profile.d.
[ ! -d ~/.bash_profile.d ] && mkdir -p ~/.bash_profile.d
${tmp_cp_script} ${opt_verbose} .bash_profile.d/home-bin.sh ~/.bash_profile.d/home-bin.sh
find ~/.bash_profile.d -type f -name '*.sh' -exec chmod u+x '{}' \;

# Install or replace the hook in the profile script.
sed -i "/^${block_start}/,/^${block_end}/d" "${profile_script}"
echo "${block_start} - ${block_warning}" >> "${profile_script}"
cat << 'EOF2' >> "${profile_script}"
if [ -n "${BASH_VERSION}" ]; then
  for script in "${HOME}"/.bash_profile.d/*.sh; do
    [ -f "${script}" ] && source "${script}"
  done
fi
EOF2
echo "${block_end} - ${block_warning}" >> "${profile_script}"

# Install or update ~/.bashrc.d.
[ ! -d ~/.bashrc.d ] && mkdir -p ~/.bashrc.d
[ ! -z "$(uname -s | grep -i cygwin)" ] && ${tmp_cp_script} ${opt_verbose} .bashrc.d/cygwin-vagrant-helper.sh ~/.bashrc.d/cygwin-vagrant-helper.sh
${tmp_cp_script} ${opt_verbose} .bashrc.d/misc-aliases.sh ~/.bashrc.d/misc-aliases.sh
${tmp_cp_script} ${opt_verbose} .bashrc.d/misc-vars.sh ~/.bashrc.d/misc-vars.sh
[ ${opt_prompt} == yes ] && ${tmp_cp_script} ${opt_verbose} .bashrc.d/prompt.sh ~/.bashrc.d/prompt.sh
[ ${opt_pip_requires_virtualenv} == yes ] && ${tmp_cp_script} ${opt_verbose} .bashrc.d/python-pip-require-virtualenv.sh ~/.bashrc.d/python-pip-require-virtualenv.sh
[ ${opt_python3_virtualenv} == yes ] && ${tmp_cp_script} ${opt_verbose} .bashrc.d/python3-virtualenv.sh ~/.bashrc.d/python3-virtualenv.sh
find ~/.bashrc.d -type f -name '*.sh' -exec chmod u+x '{}' \;

# Install or replace the hook in ~/.bashrc.
sed -i "/^${block_start}/,/^${block_end}/d" ~/.bashrc
echo "${block_start} - ${block_warning}" >> ~/.bashrc
cat << 'EOF3' >> ~/.bashrc
for script in "${HOME}"/.bashrc.d/*.sh; do
  [ -f "${script}" ] && source "${script}"
done
EOF3
echo "${block_end} - ${block_warning}" >> ~/.bashrc

# Install or update ~/bin.
[ ! -d ~/bin ] && mkdir -p ~/bin
${tmp_cp_script} ${opt_verbose} bin/gitclone.sh ~/bin/gitclone.sh
find ~/bin -type f -exec chmod u+x '{}' \;

# Delete the temporary copy script.
rm ${tmp_cp_script}
