# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# EE - Enter-Environment routines for ssh and scp operations

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

alias eep='scp ${eeid:+ -i "${eeid}"}'

# Function userconfirm - Ask a question and yield success if user responded [yY]*
unset userconfirm
userconfirm () {
    typeset confirm
    typeset result=1
    echo ${BASH_VERSION:+-e} "$@" "[y/N] \c"
    read confirm
    if [[ $confirm = [yY]* ]] ; then return 0 ; fi
    return 1
}

# Function eeauth
# Purpose:
#   Push identity file to ee environments.
# Usage:
#   eeauth [-e envregex] [-i]
# Remark:
#   -i
#       Interactive ie ask for user confirmation for each environment.
eeauth () {

    typeset pname=eeauth

    typeset expression
    typeset identfile
    typeset interactive=false

    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':e:i' opt ; do
        case "${opt}" in
        e) expression="$OPTARG";;
        i) interactive=true;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    identfile="$1"

    if ! [ -f "$identfile" ] ; then
        echo "$pname:FATAL: Bad ident file argument." 1>&2
        return 1
    fi

    for env in $(eeln -q | egrep "${expression}") ; do
        if $interactive && ! userconfirm "Push to '${env}' env?" ; then
            continue
        fi
        ee -s $env
        ssh-copy-id -i "$identfile" "${ee}"
    done
}

# Function eeauthrm
# Purpose:
#   Remove authorized key from hosts.
eeauthrm () {

    typeset pname=eeauthrm

    typeset expression
    typeset interactive=false
    typeset keytext

    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':e:i' opt ; do
        case "${opt}" in
        e) expression="$OPTARG";;
        i) interactive=true;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    keytext="$(cat "$(cygpath "$1")")"

    if [ -z "$keytext" ] ; then
        echo "$pname:FATAL: Nil public key text." 1>&2
        return 1
    fi

    for env in $(eeln -q) ; do
        if [ -n "$expression" ] && ! echogrep -q "${expression}" "${env}" ; then
            continue
        fi
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
                    grep -v '^sectionname' | \
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
                grep -v '^sectionname' | \
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

# Function eel
# Purpose:
#   Enter environment - List available environments in EEPATH's ee.txt files:
eel () {

    typeset envre
    typeset quiet=false

    # Options:
    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':e:q' option ; do
        case "${option}" in
            e) envre="$OPTARG";;
            q) quiet=true;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    while read eefile ; do

        if ! $quiet ; then
            echo "==> '${eefile}' <==" 1>&2
        fi

        awk '/^ *\[.*\] *$/ {
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
            print name ": " desc;
            waitingdesc = 0;
        }' \
            "${eefile}" | \
            egrep -i "$envre"
    done <<EOF
$(eefiles)
EOF
}

# Function eeln
# Purpose:
#   Enter environment list env names only (no description).
eeln () {

    typeset envre
    typeset quiet=false

    # Options:
    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':e:q' option ; do
        case "${option}" in
        e) envre="$OPTARG";;
        q) quiet=true;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    while read eefile ; do

        if ! $quiet ; then
            echo "==> '${eefile}' <==" 1>&2
        fi

        awk '/^ *\[.*\] *$/ {
            gsub(/[][]/, "");
            name = $0;
            if (name !~ /^groups$/) {
                print;
            }
        }' \
            "${eefile}" | \
            egrep -i "$envre"

    done <<EOF
$(eefiles)
EOF
}

# Function eesel
# Purpose:
#   Select ee environment from first occurrence in ee.txt files found in EEPATH.
eesel () {
    typeset section_search_term="$1"
    typeset section_exports

    while read eefile ; do

        section_exports="$(getsection "$section_search_term" "$eefile" | \
                    sed -e 's/[][]//g' -e 's/^/export /')"

        if [ -n "$section_exports" ] ; then

            # The egrep below is not unnecessary redundancy, it is for security:
            eval "$(echo "${section_exports}" | egrep '^export (sectionname=|ee[_a-zA-Z0-9]*=)')"

            if [ -z "${sectionname}" -o -z "$eeh" -o -z "$eeu" ] ; then
                echo "FATAL: Some of sectionname, eeh, eeu are empty." 1>&2
                return 1
            fi

            echo 1>&2
            echo "==> Selected '${eedesc:-${sectionname}}', ee='${eeu}@${eeh}' <==" 1>&2

            export ee="${eeu}@${eeh}"

            break
        fi
    done <<EOF
$(eefiles)
EOF
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
#   ... [-a | -g eegroup | -h hostname [-l login]] [ee-search-term]
#
# Remarks:
#
#   -c will use eecmd as the command. Only works when a search term is passed.
#
#   -h will override everything (search term, -a, and -g).
#   -l will only function to supply the username for the hostname in -h.
#
#   -e will only affect -a ang -g options.
#   -i will forward stdin to all calls' standard inputs.
#   -s will only select the environment and will work only when search term is given.
ee () {
    typeset doall=false
    typeset eefile eegroup eepath eestdin envre
    typeset eestdinon=false
    typeset hostarg loginarg
    typeset searchterm
    typeset selectonly=false
    typeset useentrycmd=false

    export ee=""
    export eecodename=""
    export eedesc=""
    export eedomain=""
    export eeu=""
    export eeh=""
    export eeid=""
    export eecmd=""

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
        shift

        if [ -z "${searchterm}" ] ; then
            echo 'FAIL: Must pass an env name, or one of -g eegroup, -h hostname, -a.' 1>&2
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
    elif [ -n "$searchterm" ] ; then
        eesel "$searchterm"

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
        for i in $(eeln) ; do
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
    fi
}

# ##############################################################################
