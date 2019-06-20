unalias runr >/dev/null 2>&1
runr () { "${DS_HOME:-$HOME/.ds}"/scripts/runr.sh "$@" ; }

unalias runru >/dev/null 2>&1
runru () { "${DS_HOME:-$HOME/.ds}"/scripts/runru.sh "$@" ; }
