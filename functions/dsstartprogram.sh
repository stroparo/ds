startifnone () {
  if type "$1" >/dev/null 2>&1 && ! pgrep -fl "$1" ; then
    "$@" & disown
  fi
}

startonfalse () {
  if [ $# -lt 2 ] ; then
    echo "startoncenonempty: FATAL: At least 2 args needed (expr command)." 1>&2
    return 1
  fi

  : ${DS_START_TIMEOUT:=2}
  typeset elapsed=0
  typeset expr="$1" ; shift

  while [ -z "eval $(expr)" ] ; do
    sleep 1
    elapsed=$((elapsed+1))
    if [ ${elapsed} -gt ${DS_START_TIMEOUT} ] ; then
      return 1
    fi
  done
  "$@" & disown
}
