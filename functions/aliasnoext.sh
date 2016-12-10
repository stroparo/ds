# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

aliasnoext () {
    # Info: Pick arg-dirs' scripts and yield corresponding aliases with no extension.
    # Deps: ds00 findscripts
    # Syn: {directory}1+

    typeset verbose=false

    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':v' opt ; do
        case "${opt}" in
        v) verbose=true;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    for dir in "$@" ; do
        if _all_dirs_w "${dir}" ; then
            while read script ; do
                if [[ $script = *.* ]] && [ -x "${script}" ] ; then
                    aliasname="${script##*/}"
                    aliasname="${aliasname%%.*}"
                    eval unalias "${aliasname}" 2>/dev/null
                    eval alias "${aliasname}=${script}"
                    $verbose && eval type "${aliasname}"
                fi
            done <<EOF
$(findscripts "${dir}")
EOF
        fi
    done
}

