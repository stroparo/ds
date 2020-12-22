export APTPROG=apt-get
export RPMPROG=yum
export RPMGROUP="yum groupinstall"
if which dnf >/dev/null 2>&1 ; then export RPMPROG=dnf ; export RPMGROUP="dnf group install"; fi
if which "$APTPROG" >/dev/null 2>&1 ; then export INSTPROG="$APTPROG" ; else export INSTPROG="$RPMPROG"; fi
