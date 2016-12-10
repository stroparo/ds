# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

autovimode () { appendunique 'set -o vi' "$HOME/.bashrc" "$HOME/.profile" ; }

autobash () {
    appendunique 'if [[ $- = *i* ]] && [ -z "${BASH_VERSION}" ] ; then bash ; fi' \
        "$HOME/.profile"
}
