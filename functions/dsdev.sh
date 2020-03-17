# Programming editor by default in the current dir
vs () {
  if [ -n "$1" ] ; then
    "${VISUAL}" "$@"
  else
    "${VISUAL}" .
  fi
}
