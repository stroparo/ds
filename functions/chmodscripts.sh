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

    for dir in "$@" ; do
        if _all_dirs_w "${dir}" ; then
            files=$(findscripts.sh "${dir}")
            if [ -n "$files" ] ; then
                chmod ${verbose} "${mode}" $(echo ${files})
            fi
        fi
    done

    if ${addpaths}; then pathmunge -x "$@" ; fi
    if ${addaliases}; then aliasnoext "$@" ; fi
}
