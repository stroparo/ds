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

    typeset oldind="${OPTIND}"
    typeset pname=eeauth

    typeset expression
    typeset identfile
    typeset interactive=false

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

    for env in $(eel | cut -d: -f1) ; do
        if $interactive && ! userconfirm "Push to '${env}' env?" ; then
            continue
        fi
        if [ -n "$expression" ] && ! echogrep "${expression}" "${env}" ; then
            continue
        fi
        ee -s $env
        ssh-copy-id -i "$identfile" "${eeu}@${eeh}"
    done
}

# Function eefiles - Expand ee.txt filenames from paths in EEPATH
eefiles () {
    while IFS=: read eepath ; do
        find "${eepath}" -type f -name 'ee.txt'
    done <<EOF
${EEPATH}
EOF
}

# Function eeg
# Purpose:
#   Display ee groups
eeg () {
    typeset eegroups

    while read eefile ; do

        eegroups="$(getsection "groups" "$eefile" | \
            grep -v '^sectionname' | \
            sed -e 's/=/: /')"

        if [ -n "$eegroups" ] ; then
            echo "$eegroups"
            return
        fi
    done <<EOF
$(eefiles)
EOF

    return 1
}

# Enter environment list available in EEPATH ee.txt files:
eel () {
    while IFS=: read eepath ; do
        # Search for the entry in EEPATH ee.txt files and setup variables if found:
        while read eefile ; do
            echo "==> '${eefile}' <==" 1>&2

            awk '/^ *\[.*\] *$/ {
                if (waitingdesc) {
                    print name;
                }
                gsub(/[][]/, "")
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
$(find "${eepath}" -type f -name 'ee.txt')
EOF
    done <<EOF
${EEPATH}
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
            echo "Selected env '${eedesc:-${sectionname}}' - ee=${eeu}@${eeh}" 1>&2
            ee="${eeu}@${eeh}"
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

# Function ees
# Purpose:
#   Enter-Environment select environment (sets up env. variables).
ee () {

    typeset oldind="${OPTIND}"

    typeset eefile eepath
    typeset searchterm
    typeset selectonly=false
    typeset useentrycmd=false

    export eecodename=""
    export eedesc=""
    export eedomain=""
    export eeu=""
    export eeh=""
    export eeid=""
    export eecmd=""

    OPTIND=1
    while getopts ':cs' opt ; do
        case "${opt}" in
        c) useentrycmd=true;;
        s) selectonly=true;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    searchterm="$1"
    shift

    if [ -z "${searchterm}" ] ; then
        echo 'FAIL: Must pass a nonempty environment name/id.' 1>&2
        return 1
    fi

    eesel "$searchterm"

    # Execute if the environment was found:
    if ! ${selectonly} ; then
        if $useentrycmd && [ "${eecmd}" != "" ] ; then
            eex ${eecmd}
        else
            eex "$@"
        fi
    fi
}
