# RUNR solution (stroparo/runr) wrappers

# runr - prefer it as a function instead of an
#  alias, so scripted subshells will have it:
unalias runr >/dev/null 2>&1
runr () { "${DS_HOME:-$HOME/.ds}"/scripts/runr.sh "$@" ; }

runrup () { "${DS_HOME:-$HOME/.ds}"/scripts/runr.sh -u "$@" ; }
