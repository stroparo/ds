# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

mungebinlib () {
    # Munge descendant bin* and lib* directories to PATH and library variables.
    # Syn: {directory}

    typeset mungeroot="${1}"
    [ -e "$mungeroot" ] || return 1

    pathmunge -x $(find "$mungeroot" -name 'bin*' -type d)
    pathmunge -x -v LIBPATH $(find "$mungeroot" -name 'lib*' -type d)
    export LD_LIBRARY_PATH="${LIBPATH}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
}

