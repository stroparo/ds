# DS - Daily Shells Library

cbssh () {

    # Info: Copies ~/.ssh/id_rsa.pub contents to the clipboard via the DS cb script

    if [ ! -e "${HOME}/.ssh/id_rsa.pub" ] ; then
      echo "${PROGNAME:+$PROGNAME: }SKIP: '${HOME}/.ssh/id_rsa.pub' does not exist." 1>&2
      return
    fi

    cb.sh < "${HOME}/.ssh/id_rsa.pub" || return $?
}
