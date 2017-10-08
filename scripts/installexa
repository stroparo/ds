#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

installexa_deb () {
  [ ! -d ~/bin ] && ! mkdir ~/bin && exit 1

  # Rust language
  [ -d ~/.cargo/bin ] || (curl https://sh.rustup.rs -sSf | sh)
  pathmunge -x ~/.cargo/bin

  # Deps
  sudo apt update || exit 1
  sudo apt install -y libgit2-dev cmake git libhttp-parser2.1 || exit 1

  # Compile and install exa
  git clone https://github.com/ogham/exa.git /tmp/exa \
  && (cd /tmp/exa && make install)
  if [ -f /tmp/exa/target/release/exa ] ; then
    sudo cp /tmp/exa/target/release/exa /usr/local/bin/exa \
    && ls -l /usr/local/bin/exa \
    && rm -rf /tmp/exa
  fi
}

if which exa >/dev/null 2>&1 ; then
  echo "INFO: exa already installed. Nothing done."
  exit
fi

echo ${BASH_VERSION:+-e} '\n\n==> Installing exa...' 1>&2

if ! egrep -i -q 'debian|ubuntu' /etc/*release* ; then
  installexa_deb "$@"
  exit $?
elif ! egrep -i -q 'centos|oracle|red *hat' /etc/*release* ; then
  echo "WARN: installexa_el routine still to be implemented"
fi
