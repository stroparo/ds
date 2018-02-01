# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

mungemagic () {
    # Munge descendant bin* and lib* directories to PATH and library variables.
    # Syn: {directory}

    typeset mungeroot="$(cd "${1}"; echo "$PWD")"
    [ -e "$mungeroot" ] || return 1

    if ls -d "$mungeroot"/*/ >/dev/null 2>&1 ; then
	  for child in $(ls -d "$mungeroot"/*/); do
	    pathmunge -x "$child"
	  done
	fi
    pathmunge -x $(find "$mungeroot" -name 'bin*' -type d)
    pathmunge -x -v LIBPATH $(find "$mungeroot" -name 'lib*' -type d)
    export LD_LIBRARY_PATH="${LIBPATH}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
}

