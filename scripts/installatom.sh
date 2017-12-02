#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

if which atom >/dev/null 2>&1 ; then return ; fi

if [[ "$(uname -a)" = *[Cc]ygwin* ]] ; then

  wget 'https://atom.io/download/windows'
  mv windows atomsetup.exe
  chmod u+x atomsetup.exe && ./atomsetup.exe && rm -f ./atomsetup.exe

elif egrep -i -q 'debian|ubuntu' /etc/*release* ; then

  wget 'https://atom.io/download/deb'
  sudo dpkg -i deb && rm -f deb

elif egrep -i -q 'centos|oracle|red *hat' /etc/*release* ; then

  wget 'https://atom.io/download/rpm'
  sudo rpm -ivh rpm && rm -f rpm

fi
