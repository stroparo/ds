# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# EE - Enter-Environment routines for ssh and scp operations

# Dependencies:
#   ds00.sh

# Globals:
# EEPATH (export):
#  Directories containing (recursively) ee.txt files to load entries from,
#  each entry syntax being:
#
# [entry]
# attribute=value
#
# Mandatory attributes:
# eedesc='description'
# eeu=user
# eeh=hostname
#
# Optional attributes:
# eecmd='some command'
# eeid='some .pem or other file to be handled to ssh -i option'

eecpfrom () { eesel "${1%%:*}" ; scp "${ee}:${1##*:}" "$2" ; }
eecpto () { eesel "${2%%:*}" ; scp "$1" "${ee}:${2##*:}" ; }

eeauth () {

    typeset pname=eeauth
    typeset usage="Function eeauth - Push identity file to ee environments
Syntax: [-e ee-envregex] [-i] {identfile}
Remark: -i option triggers user confirmation for each environment.
"
    typeset expression
    typeset identfile
    typeset interactive=false

    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':e:hi' opt ; do
        case "${opt}" in
            e) expression="$OPTARG";;
            h) echo "$usage" ; return ;;
            i) interactive=true;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    identfile="$1"
    ! ls -l "$identfile" && return 1

    for env in $(eel -q | egrep "${expression}") ; do
        if $interactive && ! userconfirm "Push to '${env}' env?" ; then
            continue
        fi
        ee -s $env
        ssh-copy-id -i "$identfile" "${ee}"
    done
}

eeauthrm () {

    typeset pname=eeauthrm
    typeset usage="Function eeauthrm - Remove authorized key from hosts
Syntax: {pub-key text, literal for the remote fgrep matching}
"
    typeset expression
    typeset interactive=false
    typeset keytext

    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':e:hi' opt ; do
        case "${opt}" in
            e) expression="$OPTARG";;
            h) echo "$usage" ; return ;;
            i) interactive=true;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    keytext="$1"
    [ -z "$keytext" ] && echo "$usage" && return

    for env in $(eel -q) ; do

        (echo "$env" | grep -q "${expression}") || continue

        if $interactive && ! userconfirm "Remove from '${env}' env?" ; then
            continue
        fi

        ee "$env" bash <<EOF
lineno=\$(fgrep -n '${keytext}' ~/.ssh/authorized_keys | cut -d: -f1)
if [ -n "\$lineno" ] ; then
    ex - ~/.ssh/authorized_keys <<END
\${lineno}
d
w
quit
END
fi
EOF
    done
}

# Function eefiles - Expand ee.txt filenames from paths in EEPATH
eefiles () {
    while read eepath ; do
        find "${eepath}" -type f -name 'ee.txt'
    done <<EOF
$(echo "${EEPATH}" | tr -s : '\n')
EOF
}

eeg () {
    typeset eegroupsect
    typeset eegroup
    typeset res=1
    typeset usage="
NAME
    eeg - Display all ee groups in the environment or hosts of a specific group

SYNOPSIS
    eeg [eegroup]

DESCRIPTION
    Display ee groups or when using -g eegroup, fetch only that group's env names.
"

    # Options:
    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':h' option ; do
        case "${option}" in
            h)
                echo "$usage"
                return
                ;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    while read eefile ; do
        for eegroup in "$@" ; do
            if [ -n "$eegroup" ] ; then
                eegroupsect="$(getsection "groups" "$eefile" | \
                    grep "^${eegroup}=" | \
                    sed -e 's/^[^=]*=//')"

                if [ -n "$eegroupsect" ] ; then
                        echo "$eegroupsect"
                        res=0
                fi
            fi
        done

        # Print all when no args:
        if [ "$#" -eq 0 ] ; then
            eegroupsect="$(getsection "groups" "$eefile" | \
                sed -e 's/=/: /')"

            if [ -n "$eegroupsect" ] ; then
                echo "$eegroupsect"
                res=0
            fi
        fi
    done <<EOF
$(eefiles)
EOF

    return ${res:-1}
}

eel () {
    # Enter environment - List available environments in EEPATH's ee.txt files.

    typeset verbose=0
    typeset envre
    typeset quiet=false

    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':e:qv' option ; do
        case "${option}" in
            e) envre="$OPTARG";;
            q) quiet=true;;
            v) verbose=1;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    while read eefile ; do

        if ! $quiet ; then
            echo "==> '${eefile}' <==" 1>&2
        fi

        awk -vverbose=${verbose} '

        /^ *\[.*\] *$/ {
            if (waitingdesc) {
                print name;
            }
            gsub(/[][]/, "");
            name = $0;
            if (name !~ /^groups$/) {
                waitingdesc = 1;
            }
        }

        /^ *eedesc *=/ {
            gsub(/'"'"'| *eedesc= */, "");
            desc = $0;
            if (verbose) {
                print name ": " desc;
            } else {
                print name;
            }
            waitingdesc = 0;
        }' \
            "${eefile}" | \
                egrep -i "$envre"
    done <<EOF
$(eefiles)
EOF
}

# Function eereset
# Purpose:
#   Reset ee* environment variables.
eereset () {
    export ee=''
    export eedesc=''
    export eeu=''
    export eeh=''
    export eecmd=''
    export eeid=''
    export eepath=''
    export eepw=''
}

eesel () {
    # Info: Select ee environment from first occurrence in ee.txt files found in EEPATH.

    typeset sectionname sectiontext
    typeset sectionsearch="$1"

    eereset

    while read eefile ; do

        sectionname="$(getsectionname "$sectionsearch" "$eefile")"
        sectiontext="$(getsection "$sectionsearch" "$eefile" | \
                    sed -e 's/^/export /')"

        if [ -n "$sectionname" ] && [ -n "$sectiontext" ] ; then

            # The egrep below is not unnecessary redundancy, it is for security:
            eval "$(echo "${sectiontext}" | egrep '^export ee[_a-zA-Z0-9]*=')"

            [ -z "$eeh" ] && echo "FATAL: eeh is empty." 1>&2 && return 1
            [ -z "$eeu" ] && echo "FATAL: eeu is empty." 1>&2 && return 1

            echo 1>&2
            echo "==> Selected '${eedesc:-${sectionname}}', ee='${eeu}@${eeh}' <==" 1>&2

            export ee="${eeu}@${eeh}"

            return 0
        fi
    done <<EOF
$(eefiles)
EOF

    echo "WARN: No environment found for '$sectionsearch'."
    return 1
}

# Function eex
# Purpose:
#   Enter environment execute ie connect to the environment. System command is ssh.
eex () {

    if [ -z "$eeh" ] ; then
        echo "eex:FATAL: No host in eeh variable ($eeh)." 1>&2
        return 1
    fi

    if [ -z "$eeu" ] ; then
        echo "eex:FATAL: No user in eeu variable ($eeu)." 1>&2
        return 1
    fi

    if [ -n "${eeid}" ] ; then
        ssh -i "${eeid}" -l "${eeu}" "${eeh}" "$@"
    else
        ssh -l "${eeu}" "${eeh}" "$@"
    fi
}

# Function ee
#
# Purpose:
#   Enter-Environment main function. Uses eesel and eex helpers.
#
# Syntax (TODO):
#   ee [-c] [-e envregex] [-i] [-s] ...
#   ... [-a | -g eegroup | -h hostname [-l login]] [ee-search-term] command args
#
# IMPORTANT:
#   ee-search-term must be informed only when not specifying one of -a, -g or -h.
#
# Remarks:
#
#   -c will use eecmd as the command. Only works when a search term is passed.
#
#   -h will override everything (search term, -a, and -g).
#   -l will only function to supply the username for the hostname in -h.
#
#   -e will need and only affect -a ang -g options.
#   -i will forward stdin to all calls' standard inputs.
#   -s will just select the environment (a no-op), and only if a search term is given.
ee () {
    typeset doall=false
    typeset eefile eegroup eepath eestdin envre
    typeset eestdinon=false
    typeset hostarg loginarg
    typeset searchterm
    typeset selectonly=false
    typeset usage="Pass one of:
env name
-a
-g eegroup
-h hostname (-l username)"
    typeset useentrycmd=false

    eereset

    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':ace:g:h:il:s' opt ; do
        case "${opt}" in
        a) doall=true;;
        c) useentrycmd=true;;
        e) envre="${OPTARG}";;
        g) eegroup="${OPTARG}";;
        h) hostarg="${OPTARG}";;
        i) eestdinon=true;;
        l) loginarg="${OPTARG}";;
        s) selectonly=true;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    if [ -z "$hostarg" ] && [ -z "$eegroup" ] && ! $doall ; then

        searchterm="$1"
        [ $# -gt 0 ] && shift

        if [ -z "${searchterm}" ] ; then
            echo "FATAL: ${usage}" 1>&2

            if [ -n "${envre}" ] ; then
                echo "FATAL: -e needs and only affects -a ang -g options." 1>&2
            fi

            return 1
        fi
    fi

    if ${eestdinon} ; then
        eestdin=$(cat)
    fi

    if [ -n "$hostarg" ] ; then
        export eeh="$hostarg"

        if [ -n "$loginarg" ] ; then
            export eeu="$loginarg"
        else
            export eeu="$USER"
        fi

        if ${eestdinon} ; then
            eex "$@" <<EOF
${eestdin}
EOF
        else
            eex "$@"
        fi
    elif [ -n "$eegroup" ] ; then
        for i in $(eeg $(echo ${eegroup})) ; do
            if echogrep -q "$envre" "$i" ; then
                if ${eestdinon} ; then
                    ee "$i" "$@" <<EOF
${eestdin}
EOF
                else
                    ee "$i" "$@"
                fi
            fi
        done
    elif $doall ; then
        for i in $(eel) ; do
            if echogrep -q "$envre" "$i" ; then
                if ${eestdinon} ; then
                    ee "$i" "$@" <<EOF
${eestdin}
EOF
                else
                    ee "$i" "$@"
                fi
            fi
        done
    elif [ -n "$searchterm" ] ; then

        if ! eesel "$searchterm" ; then
            return 1
        fi

        if ! ${selectonly} ; then
            if $useentrycmd && [ "${eecmd}" != "" ] ; then
                eex ${eecmd}
            elif ${eestdinon} ; then
                eex "$@" <<EOF
${eestdin}
EOF
            else
                eex "$@"
            fi
        fi
    fi
}

# ##############################################################################
