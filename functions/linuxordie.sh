linuxordie () {
  if !(uname -a | grep -i -q linux) ; then
    echo "${PROGNAME:+$PROGNAME: }SKIP: Only Linux is supported." 1>&2
    exit
  fi
}
