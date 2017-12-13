if [ -z $(echo ":${PATH}:" | egrep ".*:(${HOME}|~)/bin:.*") ]; then
  PATH="${HOME}/bin:${PATH}"
fi

