linuxordie () {
  if !(uname -a | grep -i -q linux 2>/dev/null) ; then
    echo "${PROGNAME:+$PROGNAME: }SKIP: Only Linux is supported." 1>&2
    exit
  fi
}
