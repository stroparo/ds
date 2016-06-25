# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Admin process functions

# Function alertdeadproc - Starts beeping alert on process death.
unset alertdeadproc
alertdeadproc () {
  [ -z "${1}" ] && echo 'Usage: {pid}' 1>&2 && return 1
  while [ "$(ps -T "${1}" | wc -l | cut -d' ' -f1)" -gt 0 ] ; do sleep 1 ; done
  while true ; do echo '\a' ; sleep 8 ; done
}

