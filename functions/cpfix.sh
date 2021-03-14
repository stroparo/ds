# This works well with fixing program's startup scripts, but
# will also work generically with anything else as well.
# It will do a timestamped backup every time.

cpfix () {

  # TODO test

  typeset usage="{fixed-filename} {tree-path} [launcher-path-relative-to-tree=bin/start.bat]"

  typeset file_fixed="${1}"
  typeset tree_path="${1:-${HOME}/opt/dummy_tree_path}"
  typeset file_rel_path="${2:-bin/start.bat}"
  typeset file_filename="${tree_path}/${file_rel_path}"
  typeset file_backup="${file_filename}.original-$(%Y-%m-%d-%OH-%OM-%OS)"

  if [ ! -f "${file_fixed}" ] ; then
    echo "${PROGNAME:+$PROGNAME: }INFO: Usage: ${usage}" 1>&2
    echo "${PROGNAME:+$PROGNAME: }FATAL: No fixed file path." 1>&2
    return 1
  fi

  if [ ! -d "${tree_path}" ] ; then
    echo "${PROGNAME:+$PROGNAME: }INFO: Usage: ${usage}" 1>&2
    echo "${PROGNAME:+$PROGNAME: }FATAL: No tree_path (${tree_path}) available." 1>&2
    return 1
  fi

  cp -f -v "${file_filename}" "${file_backup}"
  if [ -e "${file_backup}" ] ; then
    cp -f -v "${file_fixed}" "$(dirname "${file_filename}")/"
  fi
}
