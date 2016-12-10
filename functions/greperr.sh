# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

greperr () {
    # Info: Checks files' last line is a sole zero.
    # Remark: Common case scenario, an exit status $? logged last by a command.

    typeset grepres

    for f in "$@" ; do

        grepres="$(tail -n 1 "${f}" | grep -v '[[:space:]]*0$')"

        if [ -n "$grepres" ] ; then
            echo "==> ${f} <=="
            echo "$grepres"
        fi
    done
}
