# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Networking facilities

# Function pushl - push files to specific target environments. LFTP variant.
#
# Remarks:
# 1) The environment list must be in the tgt{env} variable.
#       Each entry in the env list must be formatted like this:
#       {environment-name}:{user}:{pass}:{host}:{destination-path}
# 2) tgtglob{env} variable might contain additional space-separated globs.
#       But when globs are passed via the -f option (-f "glob1 glob2 ...")
#       only those are going to be considered as tgtglob will
#       only serve as the default/fallback.
# 3) -r option
#       Reset files, i.e. deletes them from destination before copying.
# 4) -p option
#       Causes pushl to only purge all files in the destination
#       Usage of -r is redundant here.
#
# Syntax: [-e {env-regex}] [-f {local-globs}] [-p] [-r] {srcdir} {site} [site2 [site3 ...]]
unset pushl
pushl () {

    typeset oldind="${OPTIND}"

    typeset destdir
    typeset envregex
    typeset envpaths
    typeset exclude='@@@@DONOT@@@@'
    typeset conn
    typeset purge_only=false
    typeset readstdin=false
    typeset reset_files
    typeset srcdir
    typeset tgtglobexp
    typeset xglobs
    typeset xglobsarg

    which lftp >/dev/null 2>&1 || return 10

    OPTIND=1
    while getopts ':d:e:f:prx:' opt ; do
        case ${opt} in
        d) destdir="${OPTARG}" ;;
        e) envregex="${OPTARG}" ;;
        f) xglobsarg="${OPTARG}" ; xglobs="${OPTARG}" ;;
        p) purge_only=true ;;
        r) reset_files=true ;;
        x) exclude="${OPTARG}" ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    srcdir="$(cd ${1}; echo "$PWD")"
    shift

    if [[ -n $xglobsarg ]] ; then
        xglobs="$(cd "$srcdir" && eval echo "${xglobs}" | sed -e "s/${exclude}//g")"
    fi

    for env in "$@" ; do
        if [[ -z $xglobsarg ]] ; then
            tgtglobexp="$(eval echo "\${tgtglob${env}}")"
            xglobs="$(cd "$srcdir" && eval echo "${tgtglobexp}" | sed -e "s/${exclude}//g")"
        fi

        if [[ -z $xglobs ]]; then
            elog -f -n "$pname" "Failed expanding xglobs."
        fi

        envpaths="$(eval echo "\"\${tgt${env}}\"")"
        if $readstdin ; then
            envpaths="${envpaths}
$(cat)"
        fi

        echo "==> Env: '${env}'; Files: '${xglobs}' <=="

        while IFS=':' read environ u pw h dest ; do
            [[ -z "${u}" ]] && continue

            # Filter host name:
            if ! grep -q "${envregex}" ; then
                continue
            fi <<EOF
${environ}
EOF
            # Remote path override:
            if [ -n "$destdir" ] ; then
                if [[ $destdir = /* ]] ; then
                    dest="$destdir"
                else
                    dest="${dest}/${destdir}"
                fi
            fi

            conn="sftp://${h}/${dest#/}"

            echo "${environ} => $(${purge_only} && echo "rm in ")path: '${u}@${h}:${dest#/}'."

            if ${reset_files:-false} || ${purge_only:-false} ; then
                lftp -e 'set sftp:auto-confirm yes ; mrm -f '"${xglobs}"' ; exit' -u "${u},${pw}" "${conn}"
            fi
            ${purge_only:-false} && continue

            # Put files:
            (cd "${srcdir:-err}" \
            && lftp -e 'set sftp:auto-confirm yes ; mkdir -f -p '"${dest}"' ; mput '"${xglobs}"' ; exit' -u "${u},${pw}" "${conn}")

            if [ "$?" != 0 ] ; then
                echo "${environ} => error"\! 1>&2
                return 1
            fi
        done <<EOF
${envpaths}
EOF
    done
    echo 'Pushing process complete.' ; echo ''
}

# ##############################################################################
# Remote - Shell
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

# Function screenb - run a bash shell in a screen session.
# Syntax: [sessionname]
unset screenb
screenb () {
    screen -S "${1:-screenbash}" bash
}

# Function screenk - run a ksh shell in a screen session.
# Syntax: [sessionname]
unset screenk
screenk () {
    env ENV="${HOME}/.kshrc" screen -S "${1:-screenksh}" ksh
}

# Function sshkeygenrsa - generate id_rsa if none present for the current user.
unset sshkeygenrsa
sshkeygenrsa () {
    typeset comment="$1"
    typeset keypath="${HOME}/.ssh/id_rsa"

    if [ -e "${keypath}" ] && \
        ! userconfirm "Default '${keypath}' key already exists, enter another path?"
    then
        return
    fi

    while [ -e "${keypath}" ] ; do
        userinput "Type a path that still does not exist for your key"
        keypath="${userinput}"
    done

    while [ -z "${comment}" ] ; do
        userinput 'SSH key comment (email, name or whatever)'
        comment="${userinput}"
    done

    if ssh-keygen -t rsa -b 4096 -C "${comment:-mykey}" -f "${keypath}" ; then
        # Call the agent to add the newly generated key:
        sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/sshagent.sh"
    fi
}

# ##############################################################################

