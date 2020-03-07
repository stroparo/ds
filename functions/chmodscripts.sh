# DS - Daily Shells Library

chmodscripts () {
    # Info: Sets mode for scripts inside the specified directories.
    # Deps: ds00 aliasnoext pathmunge

    typeset addaliases=false
    typeset addpaths=false
    typeset files
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

    chmod ${verbose} "${mode}" $(echo $(findscripts.sh "$@"))

    if ${addpaths}; then pathmunge -x "$@" ; fi
    if ${addaliases}; then aliasnoext "$@" ; fi
}
