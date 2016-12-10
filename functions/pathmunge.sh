# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

pathmunge () {
    # Info: prepend (-a causes to append) directory to PATH global.
    # Syn: [-v varname] [-x] {path}1+
    # Remark:
    #   -x causes variable to be exported.

    typeset doexport=false
    typeset mungeafter=false
    typeset varname=PATH
    typeset mgdpath mgdstring previous

    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':av:x' opt ; do
        case "${opt}" in
        a) mungeafter=true ;;
        v) varname="${OPTARG}" ;;
        x) doexport=true ;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    for i in "$@" ; do
        mgdpath="$(eval echo "\"${i}\"")"
        previous="$(eval echo '"${'"${varname}"'}"')"

        if ${mungeafter} ; then
            mgdstring="${previous}${previous:+:}${mgdpath}"
        else
            mgdstring="${mgdpath}${previous:+:}${previous}"
        fi

        eval "${varname}='${mgdstring}'"
    done

    if ${doexport} ; then eval export "${varname}" ; fi
}

