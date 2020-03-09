# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

export APTPROG=apt

export RPMPROG=yum
export RPMGROUP="yum groupinstall"
if [ -e /sbin/dnf ] ; then
  export RPMPROG=dnf
  export RPMGROUP="dnf group install"
fi

if [ -e /sbin/apt ] ; then
  export INSTPROG="$APTPROG"
else
  export INSTPROG="$RPMPROG"
fi
