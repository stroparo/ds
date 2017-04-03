# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Networking

# Oneliners
iwf () { iwconfig ; ifconfig ; }

pushds () {
    # Info:
    #   Push ds scripts and source files to envs pointed to by arguments, packed into
    #   an archive whose filename starts with DS directory's basename eg 'ds.tar.gz'.
    # Option -d new-ds-home overrides DS_HOME as the default DS directory.

    typeset dsarchive dsbase dsdir dsparent
    typeset dsarchivedir="$HOME"
    typeset envre
    typeset extension='.tar.gz'
    typeset excludeERE='====@@@@DUMMYEXCLUDE@@@@===='
    typeset oldind="$OPTIND"
    typeset optdirs="${DS_HOME}"

    OPTIND=1
    while getopts ':d:e:x:' opt ; do
        case ${opt} in
        d) optdirs="$OPTARG";;
        e) envre="$OPTARG";;
        x) excludeERE="$OPTARG";;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="$oldind"

    while read dsdir ; do

        if [ -n "${dsdir}" ] && [ ! -d "${dsdir}" -o ! -r "${dsdir}" ] ; then
            echo "FATAL: dsdir='${dsdir}' is not a valid directory." 1>&2
            return 1
        fi

        dsarchive="${dsarchivedir}/$(basename "${dsdir}")${extension}"
        dsbase="$(basename "${dsdir}")"
        dsparent="$(cd "${dsdir}" && cd .. && echo "$PWD")"

        if [ -z "$dsbase" -o -z "$dsparent" ] ; then
            echo "FATAL: Could not obtain dirname and basename of dsdir='${dsdir}'." 1>&2
            return 1
        fi

        tar -C "${dsparent}" -cf - \
            $(cd "${dsparent}" && find "${dsbase}" -type f | egrep -v "/[.]git|$excludeERE") | \
            gzip -c - > "${dsarchive}"
    done <<EOF
$(echo "$optdirs" | tr -s , '\n')
EOF

    pushl -r -e "$envre" -f "ds*${extension}" -s "${dsarchivedir}" "$@"
    res=$?
    ([ "$res" -eq 0 ] && cd "${dsarchivedir}" && rm -f ds*"${extension}")
    return ${res:-1}
}

