# Vagrant needs help using Cygwin.
if [ ! -z "$(uname -s | grep -i cygwin)" ]; then
  export VAGRANT_DETECTED_OS=cygwin
fi

