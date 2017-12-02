# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################

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
