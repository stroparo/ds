# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Cygwin routines

_is_cygwin || return 0

cyd () {
    # Info: cd to the disk drive letter argument; fails if not in cygwin.
    # Syn: cyd {a|b|c|d|e|f|...}
    _is_cygwin && cd /cygdrive/"${1:-c}" && ls -AFhl 1>&2
}

