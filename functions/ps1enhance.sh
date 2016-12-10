# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

ps1enhance () {
    # Info: Make PS1 better, displaying user, host, time, $? and current dir.

    if [ -n "${BASH_VERSION}" ] ; then
        export PS1='[\[\e[32m\]\u@\h\[\e[0m\] \t \$?=$? \W]\$ '
    elif [[ $0 = *ksh* ]] && [[ ${SHELL} = *ksh ]] ; then
        export PS1='[${USER}@$(hostname) $(date '+%OH:%OM:%OS') \$=$? ${PWD##*/}]\$ '
    fi
}
