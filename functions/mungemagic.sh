# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

mungemagic () {
    # Munge descendant bin* and lib* directories to PATH and library variables.
    # Syn: {directory}

    typeset mungeroot="$(cd "${1}"; echo "$PWD")"
    [ -e "$mungeroot" ] || return 1

    pathmunge -x "$mungeroot"{,/bin}
    pathmunge -x -v LIBPATH "$mungeroot"/lib
    if ls -d "$mungeroot"/*/ >/dev/null 2>&1 ; then
      for child in $(ls -d "$mungeroot"/*/); do
        pathmunge -x "$child"{,/bin}
        pathmunge -x -v LIBPATH "$child"/lib
      done
    fi
    export LD_LIBRARY_PATH="${LIBPATH}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
}

