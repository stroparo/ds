#!/usr/bin/env sh

export DS_HOME="${1:-${HOME}/.ds}"
export PROFILE_PATH="${2:-${HOME}/.bashrc}"

export SOURCE_DS_CODE=". '${DS_HOME}/ds.sh' '${DS_HOME}'"

checkEnv () {

    if [ ! -r "${DS_HOME}/ds.sh" ] ; then

        echo "FATAL: DS_HOME='${DS_HOME}' must be the DS directory." 1>&2
        exit 1

    elif [ -e "${PROFILE_PATH}" ] ; then

        if [ ! -r "${PROFILE_PATH}" -o ! -w "${PROFILE_PATH}" ] ; then
            echo "FATAL: there is a profile ('${PROFILE_PATH}') already, but it was not fully accessible (rw)." 1>&2
            exit 1
        fi

        if grep 'ds.sh' "${PROFILE_PATH}" /dev/null ; then
            echo "SKIP: DS already exists in the profile. Nothing done." 1>&2
            exit
        fi

    fi
}

main () {

    if . "${DS_HOME}/ds.sh" "${DS_HOME}" && ${DS_LOADED:-false}; then

        # Sourced DS, so now append it to the profile:

        if egrep -q '([.]|source) .*/ds.sh' "${PROFILE_PATH}" 2>/dev/null && \
            egrep -q '^[^#]*/ds.sh' "${PROFILE_PATH}" 2>/dev/null
        then
            echo "SKIP: DS already exists in the profile. Nothing done." 1>&2
            exit
        else
            appendunique "${SOURCE_DS_CODE}" "${PROFILE_PATH}"
        fi

    else
        echo "DS_HOME=${DS_HOME}" 1>&2
        echo "PROFILE_PATH=${PROFILE_PATH}" 1>&2
        echo "FATAL: DS could not be setup into the environment's profile." 1>&2
    fi
}

checkEnv
main
