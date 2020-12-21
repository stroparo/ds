vs () {
  # Open the programming editor (command name in the 'VISUAL' global) in the current dir. by default.
  # If any args. specifieds each of these will be a directory to run the editor with (as an argument).

  typeset first="${1:-$PWD}"

  if [ -z "${1}" ] ; then
    echo "vs(): INFO: No first argument so will use PWD='${PWD}' instead for that one..."
  else
    shift
  fi

  for vs_dir in "${first}" "$@" ; do
    if [ -z "${vs_dir}" ] ; then continue ; fi
    "${VISUAL}" "${vs_dir}"
  done
}
