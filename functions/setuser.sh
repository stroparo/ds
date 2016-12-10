# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

userconfirm () {
    # Info: Ask a question and yield success if user responded [yY]*

    typeset confirm
    typeset result=1

    echo ${BASH_VERSION:+-e} "$@" "[y/N] \c"
    read confirm
    if [[ $confirm = [yY]* ]] ; then return 0 ; fi
    return 1
}

userinput () {
    # Info: Read value to variable userinput.

    echo ${BASH_VERSION:+-e} "$@: \c"
    read userinput
}
