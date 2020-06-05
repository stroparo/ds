#!/usr/bin/env bash

if ! egrep -i -q -r 'ubuntu' /etc/*release ; then exit ; fi

PPA="$1"
PKG="$2"
export APTPROG=apt-get


if ! (ls -d /etc/apt/sources.list.d/* | fgrep -q "$(echo "${PPA}" | sed -e 's/[/-].*$//')") ; then
  sudo add-apt-repository -y "ppa:${PPA}"
fi

if ! dpkg -s "${PKG}" ; then
  sudo ${APTPROG} install -y "${PKG}"
fi
