# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# AIX admin & ops functions

aixloadbull () {
    typeset bullpath="$1"

    if [ ! -e "$bullpath" ] ; then
        return
    fi

    pathmunge -x $(find "$bullpath" -name 'bin*' -type d)
    pathmunge -a -x -v LIBPATH $(find "$bullpath" -name 'lib*' -type d)
    export LD_LIBRARY_PATH="$LIBPATH"
}
