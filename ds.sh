#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in stroparo/ds project at github.

# ##############################################################################
# DS setup

# Params

export DS_HOME="${1:-${HOME}/bin}"
export DS_VERSION='ver. 0.0.1 - 2015-04-08 01:25'

# Aliases

alias envinfo='_env_info'

# Functions

dshelp () {
    echo 'DS - Daily Shells Library - Help

Commands:

dshelp:     displays this help messsage.
dsversion:  displays version for this DS instance.
envinfo:    displays environment information (_env_info private function).
' 1>&2
}

dsversion () {
    echo "Daily Shells - ${DS_VERSION}" 1>&2
}

# This is standard and shall be overriden by your own fork:
_env_info () {
    dsversion
    echo "DS_HOME='${DS_HOME}'"
}

# Functions - private

_alias_no_sh_ext () {
    cd "${1:-${HOME}/bin}" && \
    ls -1 *sh | \
    while read script ; do
        if [ -x "${script}" ] ; then
            eval alias "${script%.*}=${script}"
        fi
    done
}

_src_profiles () {

    typeset profilelist="$(cat "${1}"/*profilelist* 2>/dev/null)"

    for profile in ${profilelist} ; do
        echo "Sourcing '$(eval echo ${profile})'..." 1>&2
        . "$(eval echo ${profile})" 1>&2
    done

}

_src_utils () {

    typeset utilslist="$(ls -1 "${1}"/*utilslist* 2>/dev/null)"

    for utils_file in ${utilslist} ; do
        echo "Sourcing '$(eval echo ${utils_file})'..." 1>&2
        . "$(eval echo ${utils_file})" 1>&2
    done

}

# ##############################################################################
# General goodies


# Shell setup

# Source default bashrc in etc when available:
#[ -f /etc/bashrc ] && . /etc/bashrc

# Turn on Vi Mode, which allows for command line editing with vi-like commands:
set -o vi


# Params

export PATH="${HOME}/bin${PATH:+:${PATH}}"

# PS1
if [ -n "${BASH_VERSION}" ] ; then
    #export PS1='[\u@\h \t \$?=$? \W]\$ '
    # Highlight user@host:
    export PS1='[\[\e[32m\]\u@\h\[\e[0m\] \t \$?=$? \W]\$ '
elif [[ $0 = *ksh* ]] && [[ ${SHELL} = *ksh ]] ; then
    export PS1='[${USER}@$(hostname) $(date '+%OH:%OM:%OS') \$=$? ${PWD##*/}]\$ '
fi


# Aliases

alias l='ls -Fl'
alias ll='ls -FlA'
alias lt='ls -Fltr'
alias xcd="alias | egrep \"'c?d \""
alias xhome='cd ~/bin && chmod 740 *sh'

# Specific for GNU environments:
if (ls --version 2>/dev/null | grep -q GNU) ; then
    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias ls='ls --color=auto'

    alias l='ls -Fhl'
    alias ll='ls -FhlA'
fi

# Specific for IBM AIX:
if [[ $(uname) = *AIX* ]] ; then
    alias pst1='ps -fT1'
    alias pstu='ps -fT1|awk "\$1 ~ /^$USER$/"'
    alias topu='topas -U "$USER" -P'
fi


# Functions

# cyg - (available only in cygwin) goes to the given disk drive letter.
# Syntax: cyg {a|b|c|d|e|f|...}
if (uname -a | grep -i -q cygwin) ; then
    unset cyg 2>/dev/null
    cyg () {
        d /cygdrive/"${1:-c}" -Ah
    }
fi

# ckenv - check environment function
#  Checks no. of arguments, plus
#  sets hasgnu (stands for "has GNU?")
ckenv () {
    typeset args_slice_min="${1}"
    typeset args_slice_max="${2:-1}"
    shift 2

    if ! [ "${#}" -ge "${args_slice_min:-0}" -a "${#}" -le "${args_slice_max:-1}" ] ; then
        echo "Bad arguments.."
        echo "${usage:-There was no 'usage' variable set.}"
        exit 1
    fi

    # hasgnu - "has GNU?" portability indicator
    find --version 2> /dev/null | grep -i -q 'gnu'
    if [ "$?" -eq 0 ] ; then
        export hasgnu=true
    fi
}

# d - Convenient change directory command (changes dir and performs an ls).
unset d
d () {
    dir="${1}"
    shift

    cd "${dir}"
    pwd
    ls -Fl "$@"
}

# dos2unix - remove CR (0x0d) characters from Windows end-of-line sequences (CR+LF), yielding Unix EOL (LF).
# Syntax: dos2unix file
unset dos2unix
dos2unix () {
    for i in "$@" ; do
        echo "Delete '${i}' CR chars; write to '${i}.u' the rename it to original '${i}'..."
        tr -d '\r' < "${i}" > "${i}.u"
        mv "${i}.u" "${i}"
    done
}

# loop - pass it a command and run it every t seconds (override with the '-d t' option).
# Syntax: loop command
unset loop
loop () {
    typeset interval=10
    while getopts ':d:' opt ; do
        case "${opt}" in
            d)
                interval="${OPTARG}"
                ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    while true ; do
        clear 2>/dev/null || echo ''
        echo "Looping thru every ${interval} seconds.."
        echo "Command:" "$@"
        $@
        sleep "${interval}" 2>/dev/null \
        || sleep 10 \
        || break
    done
}

# mucat - cat multiple files.
# Syntax: mucat file1[ file2[ file3 ...]]
unset mucat
mucat () {
    typeset first=true

    for f in "$@" ; do
        ${first} || echo ''

        echo "==> ${f} <=="
        cat "${f}"

        first=false
    done
}

# mutail - tail multiple files.
# Syntax: mutail [-l lines] file1[ file2[ file3 ...]]
unset mutail
mutail () {
    typeset first=true
    typeset lines=10

    while getopts ':l:' opt ; do
        case "${opt}" in
            l)
                lines="${OPTARG}"
                ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    for f in "$@" ; do
        ${first} || echo ''

        echo "==> ${f} <=="
        tail -n ${lines:-10} "${f}"

        first=false
    done
}

# pgr - pgrep emulator.
unset pgr
pgr () {
    ps -ef \
    | egrep -i "${1}" \
    | egrep -v "grep.*(${1})"
}


# Functions - agg:

# Usage: getmax sep field files...
getmax () {

    typeset sep="${1}"
    typeset field="${2}"
    shift 2

    awk -F"${sep}" -vfield="${field}" '
        BEGIN {
            max = 0;
        }

        {
            if (max < $field) max = $field;
        }

        END {
            print max;
        }
    ' "$@"

}

# Usage: getmin sep field files...
getmin () {

    typeset sep="${1}"
    typeset field="${2}"
    shift 2

    awk -F"${sep}" -vfield="${field}" '
        BEGIN {
            min = 2147483648;
        }

        {
            if (min > $field) min = $field;
        }

        END {
            print min;
        }
    ' "$@"

}

# Usage: getsum sep field files...
getsum () {

    typeset sep="${1}"
    typeset field="${2}"
    shift 2

    awk -F"${sep}" -vfield="${field}" '
        BEGIN {
            sum = 0;
        }

        {
            sum += $field;
        }

        END {
            print sum;
        }
    ' "$@"

}


# ##############################################################################
# Specific routines for this DS variant

# YOUR CUSTOM ROUTINES HERE

# ##############################################################################
# Main

_alias_no_sh_ext "${DS_HOME}"
_src_profiles "${DS_HOME}"
_src_utils "${DS_HOME}"
_env_info

# Specific calls for this DS variant:
# YOUR CUSTOM CALLS HERE
