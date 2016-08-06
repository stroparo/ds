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

    for env in $(eeln) ; do
        if [ -n "$expression" ] && ! echogrep -q "${expression}" "${env}" ; then
            continue
        fi
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
unset eeauthrm
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

    for env in $(eeln) ; do
        if [ -n "$expression" ] && ! echogrep -q "${expression}" "${env}" ; then
            continue
        fi
        if $interactive && ! userconfirm "Remove from '${env}' env?" ; then
            continue
        fi

        ee "$env" <<EOF
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

# Function eeg
# Purpose:
#   Display ee groups or when using -g eegroup, fetch only that group's env names.
# Syntax:
#   eeg [-g eegroup]
eeg () {
    typeset eegroups
    typeset eegroup
    typeset res=1

    # Options:
    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':g:' option ; do
        case "${option}" in
        g) eegroup="${OPTARG}";;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"   

    while read eefile ; do

        if [ -n "$eegroup" ] ; then
            # Looking for a specific group only:

            eegroups="$(getsection "groups" "$eefile" | \
                grep -v '^sectionname' | \
                grep "^${eegroup}=" | \
                sed -e 's/^[^=]*=//')"

            if [ -n "$eegroups" ] ; then
                echo "$eegroups"
                return 0
            fi
        else # No eegroup, so task is to print all groups in friendly format.
            eegroups="$(getsection "groups" "$eefile" | \
                grep -v '^sectionname' | \
                sed -e 's/=/: /')"

            if [ -n "$eegroups" ] ; then
                res=0
                echo "$eegroups"
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
    while read eefile ; do

        echo "==> '${eefile}' <==" 1>&2

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
        "${eefile}"
    done <<EOF
$(eefiles)
EOF
}

# Function eeln
# Purpose:
#   Enter environment list env names only (no description).
eeln () {
    while read eefile ; do

        echo "==> '${eefile}' <==" 1>&2

        awk '/^ *\[.*\] *$/ {
            gsub(/[][]/, "");
            name = $0;
            if (name !~ /^groups$/) {
                print;
            }
        }' \
        "${eefile}"
    done <<EOF
$(eefiles)
EOF
}

# Function eesel
# Purpose:
#   Select ee environment from first occurrence in ee.txt files found in EEPATH.
eesel () {
    typeset section_search_term="$1"
    typeset section

    while read eefile ; do

        section="$(getsection "$section_search_term" "$eefile" | sed -e 's/^/export /')"

        if [ -n "$section" ] ; then
            eval "$section"
        fi
        if [ -n "${sectionname}" ] ; then
            echo
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
# Purpose:
#   Enter-Environment main function. Uses eesel and eex helpers.
# Syntax:
#   ee -
ee () {
    typeset doall=false
    typeset eefile eepath
    typeset eegroup
    typeset envre
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
    while getopts ':ae:g:cs' opt ; do
        case "${opt}" in
        a) doall=true;;
        e) envre="${OPTARG}";;
        g) eegroup="${OPTARG}";;
        c) useentrycmd=true;;
        s) selectonly=true;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    if [ -z "$eegroup" ] && ! $doall ; then
        searchterm="$1"
        shift
    fi

    if [ -z "${searchterm}" ] && [ -z "$eegroup" ] && ! $doall ; then
        echo 'FAIL: Must pass an env name, or -g eegroup, or -a.' 1>&2
        return 1
    fi

    if [ -n "$searchterm" ] ; then
        eesel "$searchterm"

        if ! ${selectonly} ; then
            if $useentrycmd && [ "${eecmd}" != "" ] ; then
                eex ${eecmd}
            else
                eex "$@"
            fi
        fi
    elif [ -n "$eegroup" ] ; then
        for i in $(eeg -g "$eegroup") ; do
            if echogrep -q "$envre" "$i" ; then
                ee "$i" "$@"
            fi
        done
    elif $doall ; then
        for i in $(eeln) ; do
            if echogrep -q "$envre" "$i" ; then
                ee "$i" "$@"
            fi
        done
    fi
}
