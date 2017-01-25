# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

chmodshells () {
    # Info: Sets mode for scripts inside the specified directories.
    # Deps: ds00 aliasnoext pathmunge

    typeset addaliases=false
    typeset addpaths=false
    typeset mode='u+rwx'
    typeset verbose

    typeset oldind="$OPTIND"
    OPTIND=1
    while getopts ':am:pv' opt ; do
        case "${opt}" in
        a) addaliases=true ;;
        m) mode="${OPTARG}" ;;
        p) addpaths=true ;;
        v) verbose='-v' ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    for dir in "$@" ; do
        if _all_dirs_w "${dir}" ; then
            chmod ${verbose} "${mode}" $(findscripts "${dir}")
        fi
    done

    if ${addpaths}; then pathmunge -x "$@" ; fi
    if ${addaliases}; then aliasnoext ${verbose} "$@" ; fi
}
