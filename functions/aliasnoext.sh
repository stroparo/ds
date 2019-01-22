# DS - Daily Shells Library

aliasnoext () {
    # Info: Pick arg-dirs' scripts and yield corresponding aliases with no extension.
    # Deps: ds00 findscripts
    # Syn: {directory}1+

    typeset aliasname scriptbasename scripts
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

            scripts=$(findscripts.sh "${dir}")
            [ -z "$scripts" ] && continue

            while read script ; do
                if [ -x "${script}" ] ; then

                    scriptbasename="${script##*/}"
                    aliasname="${scriptbasename%%.*}"

                    if [ "${aliasname}" != "${scriptbasename}" ] && ! type "${aliasname}" >/dev/null 2>&1; then
                        eval unalias "${aliasname}" 2>/dev/null
                        eval alias "${aliasname}=${script}"
                        $verbose && eval type "${aliasname}"
                    fi
                else
                    echo chmod u+x "${script}" 1>&2
                    chmod u+x "${script}"
                fi
            done <<EOF
${scripts}
EOF
        fi
    done
}

