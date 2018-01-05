#!/usr/bin/env bash

# Daily Shells Library
# More instructions and licensing at:
# https://github.com/stroparo/ds

# Info: Call configure, make & makeinstall for custom dir/prefix.
# Rmk: Default prefix is ~/opt/root
# Syn: {prefix directory}

 mkdir "${1:-${HOME}/opt/root}" 2> /dev/null || exit 1

./configure --prefix="${1:-${HOME}/opt/root}" \
  && make \
  && make install
