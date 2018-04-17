# DS - Daily Shells Library

# #############################################################################

setlogdir () {
  # Info: Create and check log directory.
  # Syntax: {log-directory}

  typeset logdir="${1}"

  mkdir -p "${logdir}" 2>/dev/null

  if [ ! -d "${logdir}" -o ! -w "${logdir}" ] ; then
    echo "FATAL: '$logdir' log dir unavailable." 1>&2
    return 10
  fi
}
