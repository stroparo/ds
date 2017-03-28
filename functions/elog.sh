# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# DEPRECATED: kept here for backwards compatibility only

elog () {
    # Info: Echo a string to standard error.

    typeset msgtype="INFO"
    typeset pname
    typeset verbosecondition

    typeset oldind="$OPTIND"
    OPTIND=1
    while getopts ':dfin:svw' opt ; do
        case "${opt}" in
            d) msgtype="DEBUG" ;;
            f) msgtype="FATAL" ;;
            i) msgtype="INFO" ;;
            n) pname="${OPTARG}" ;;
            s) msgtype="SKIP" ;;
            v) verbosecondition=true ;;
            w) msgtype="WARNING" ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    if [ -z "${verbosecondition}" -o -n "${DS_VERBOSE}" ] ; then
        echo "${pname:+${pname}:}${msgtype:+${msgtype}:}" "$@" 1>&2
    fi
}
