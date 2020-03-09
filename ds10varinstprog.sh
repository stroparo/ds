export APTPROG=apt
export RPMPROG=yum
export RPMGROUP="yum groupinstall"
if [ -e /sbin/dnf ] ; then export RPMPROG=dnf ; export RPMGROUP="dnf group install"; fi
if [ -e /sbin/apt ] ; then export INSTPROG="$APTPROG" ; else export INSTPROG="$RPMPROG"; fi
