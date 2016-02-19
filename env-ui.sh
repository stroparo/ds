# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# UI & CLI functions

echodots () {
    trap return SIGPIPE
    while sleep "${1:-200}" ; do echo '.' ; done
}
