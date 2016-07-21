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
# ee_desc='description'
# ee_user=user
# ee_host=hostname
#
# Optional attributes:
# ee_cmd='some command'
# ee_id='some .pem or other file to be handled to ssh -i option'

alias eep='scp ${ee_id:+ -i "${ee_id}"}'

eeauth () {

    typeset identfile="$1"

    # TODO implement option to prompt for each entry..

    # TODO echo proper validation error:
    test -f "$identfile" || return 1

    for env in $(eel|cut -d: -f1) ; do
        ee -s $env
        ssh-copy-id -i "$identfile" "${ee_user}@${ee_host}"
    done
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
                waitingdesc = 1;
            }

            /^ *ee_desc *=/ {
                gsub(/'"'"'| *ee_desc= */, "");
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

# Enter environment execute ie connect to the environment. System command is ssh.
eex () {
    if test -n "${ee_cmd}" && test -z "${1}" ; then
        echo 'WARN: There is ee_cmd set but this eex call has no arguments.' 1>&2
    fi

    if [ -n "${ee_id}" ] ; then
        ssh -i "${ee_id}" -l "${ee_user}" "${ee_host}" "$@"
    else
        ssh -l "${ee_user}" "${ee_host}" "$@"
    fi
}

# Function ees - Enter-Environment select environment (sets up env. variables).
ee () {
    typeset oldind="${OPTIND}"
    typeset ee_name_search eefile eepath selectonly
    ee_name=""; ee_desc=""; ee_user=""; ee_host=""; ee_domain=""; ee_id=""; ee_cmd=""

    OPTIND=1
    while getopts ':s' opt ; do
        case "${opt}" in
        s) selectonly=true ;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    ee_name_search="$1"
    shift

    if [ -z "${ee_name_search}" ] ; then
        echo 'FAIL: Must pass a nonempty environment name/id.' 1>&2
        return 1
    fi

    # Search for the entry in EEPATH ee.txt files and setup variables if found:
    while IFS=: read eepath ; do
        while read eefile ; do
            eval "$(awk -vee_name_search="${ee_name_search}" '

            # Find the entry:
            /^ *\['"${ee_name_search}"'\] *$/ { found = 1; print "ee_name=" ee_name_search; }

            # Print entry content:
            found && $0 ~ /^ *[^[]/ { inbody = 1; print; }

            # Stop on next entry after printing:
            inbody && $0 ~ /^ *\[/ { exit 0; }
            ' "${eefile}")"

            test -n "${ee_name}" && break
        done <<EOF
$(find "${eepath}" -type f -name 'ee.txt')
EOF
        test -n "${ee_name}" && break
    done <<EOF
${EEPATH}
EOF
    # Execute if the environment was found:
    if test -n "${ee_name}" ; then
        if test -n "${selectonly}" ; then
            echo "Selected '${ee_desc:-${env_name}}': ${ee_user}@${ee_host}"
        else
            if [ "${ee_cmd}" != "" ] ; then
                eex ${ee_cmd}
            else
                eex "$@"
            fi
        fi
        return 0
    fi

    echo "No environment found." 1>&2
    return 1
}
