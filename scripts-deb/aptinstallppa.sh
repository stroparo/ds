#!/usr/bin/env bash

PPA="$1"
PKG="$2"

if ! egrep -i -q -r 'ubuntu' /etc/*release ; then exit ; fi
export APTPROG=apt-get; which apt >/dev/null 2>&1 && export APTPROG=apt

if ! ls -d *(echo "${PPA}" | sed -e 's/[/-].*//')* >/dev/null 2>&1 ; then
  sudo add-apt-repository -y "ppa:${PPA}"
fi

if ! dpkg -s "${PKG}" ; then
  sudo ${APTPROG} install -y "${PKG}"
fi
