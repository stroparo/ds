# This works well with fixing program's startup scripts, but
# will also work generically with anything else as well.
# It will do a timestamped backup every time.

cpfix () {

  # TODO test

  typeset usage="{fixed-filename} {target-tree-path} [target-filename-relative-to-tree=bin/start.bat]"

  typeset filename_fixed="${1}"
  typeset target_tree_path="${2:-${HOME}/opt/dummy_target_tree_path}"
  typeset target_rel_filename="${3:-bin/start.bat}"
  typeset target_filename="${target_tree_path}/${target_rel_filename}"
  typeset target_backup_filename="${target_filename}.original-$(%Y-%m-%d-%OH-%OM-%OS)"

  if [ ! -f "${filename_fixed}" ] ; then
    echo "${PROGNAME:+$PROGNAME: }INFO: Usage: ${usage}" 1>&2
    echo "${PROGNAME:+$PROGNAME: }FATAL: No fixed file path." 1>&2
    return 1
  fi

  if [ ! -d "${target_tree_path}" ] ; then
    echo "${PROGNAME:+$PROGNAME: }INFO: Usage: ${usage}" 1>&2
    echo "${PROGNAME:+$PROGNAME: }FATAL: No target_tree_path (${target_tree_path}) available." 1>&2
    return 1
  fi

  cp -f -v "${target_filename}" "${target_backup_filename}"
  if [ -e "${target_backup_filename}" ] ; then
    cp -f -v "${filename_fixed}" "${target_filename}"
  fi
}
