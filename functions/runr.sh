# RUNR solution (stroparo/runr) wrappers

# Prefer these as functions over aliases so scripted subshells will have access:

unalias runr >/dev/null 2>&1
runr () { "${DS_HOME:-$HOME/.ds}"/scripts/runr.sh "$@" ; }

unalias runrup >/dev/null 2>&1
runrup () { "${DS_HOME:-$HOME/.ds}"/scripts/runr.sh -u "$@" ; }
