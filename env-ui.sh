# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# UI & CLI functions

# Function echodots - Echoes dots between 200s or number of seconds in arg1.
unset echodots
echodots () {
    trap return SIGPIPE
    while sleep "${1:-200}" ; do echo '.' ; done
}

# Function ps1enhance - make PS1 better, displaying user, host, time, $? and the current directory.
unset ps1enhance
ps1enhance () {
    if [ -n "${BASH_VERSION}" ] ; then
        export PS1='[\[\e[32m\]\u@\h\[\e[0m\] \t \$?=$? \W]\$ '
    elif [[ $0 = *ksh* ]] && [[ ${SHELL} = *ksh ]] ; then
        export PS1='[${USER}@$(hostname) $(date '+%OH:%OM:%OS') \$=$? ${PWD##*/}]\$ '
    fi
}

