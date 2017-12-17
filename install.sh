#!/usr/bin/env bash

echo_usage() { 
  echo "This script will install the various files for my environment."
  echo
  echo "Usage: ${0} [-v]"
  echo
  echo "  -h  Show this help information."
  echo "  -v  Verbose output."
} 

opt_verbose=no

while getopts ":hdlrt:v" opt; do
  case "${opt}" in
    h)
      echo_usage ${0}
      exit 0
      ;;
    v)
      opt_verbose=yes
      ;;
    \?)
      echo "${0}: Error: Invalid option: -${optarg}" >&2
      echo_usage ${0}
      exit 1
      ;;
  esac
done

script_dir=$(dirname ${BASH_SOURCE[0]})
cd ${script_dir}

# Create a temporary copy script.
tmp_cp_script=$(mktemp --tmpdir tmp_cp_XXXXXXXXXX.sh)
cat << 'EOF1' > ${tmp_cp_script}
#!/usr/bin/env bash

# This script is used in order to avoid using multiple '{}' arguments in the '-exec' clause of the calling 'find'.
# By 'find' standard, behavior using multiple '{}' arguments in the '-exec' clause is unspecified.

cp --no-preserve=mode "${1}" ~/"${1}"
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

# Install or replace ~/.bash_profile.d.
if [ -d ~/.bash_profile.d ]; then
  rm -rf ~/.bash_profile.d
fi
find .bash_profile.d -type d -exec mkdir -p ~/'{}' \;
find .bash_profile.d -type f -exec ${tmp_cp_script} '{}' \;
find ~/.bash_profile.d -type f -name '*.sh' -exec chmod u+x '{}' \;

# Install or replace the ~/.bash_profile.d script calls in the profile script.
sed -i "/^${block_start}/,/^${block_end}/d" ${profile_script}
echo "${block_start} - ${block_warning}" >> ${profile_script}
cat << 'EOF2' >> ${profile_script}
if [ -n "${BASH_VERSION}" ]; then
  for script in "${HOME}"/.bash_profile.d/*.sh; do
    [ -f "${script}" ] && source "${script}"
  done
fi
EOF2
echo "${block_end} - ${block_warning}" >> ${profile_script}

# Install or replace ~/.bashrc.d.
if [ -d ~/.bashrc.d ]; then
  rm -rf ~/.bashrc.d
fi
find .bashrc.d -type d -exec mkdir -p ~/'{}' \;
find .bashrc.d -type f -exec ${tmp_cp_script} '{}' \;
find ~/.bashrc.d -type f -name '*.sh' -exec chmod u+x '{}' \;

# Install or replace the ~/.bashrc.d script calls in ~/.bashrc.
sed -i "/^${block_start}/,/^${block_end}/d" ~/.bashrc
echo "${block_start} - ${block_warning}" >> ~/.bashrc
cat << 'EOF3' >> ~/.bashrc
for script in "${HOME}"/.bashrc.d/*.sh; do
  [ -f "${script}" ] && source "${script}"
done
EOF3
echo "${block_end} - ${block_warning}" >> ~/.bashrc

# Delete the temporary copy script.
rm ${tmp_cp_script}
