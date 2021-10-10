cbssh () {
    # Info: Copies ~/.ssh/id_rsa.pub contents to the clipboard via the DRYSL (DRY Scripting Library) 'cb' script

    typeset sshpubkey="${1:-${HOME}/.ssh/id_rsa.pub}"

    if [ ! -e "${sshpubkey}" ] ; then
      echo "${PROGNAME:+$PROGNAME: }SKIP: '${sshpubkey}' does not exist." 1>&2
      return
    fi

    cb.sh < "${sshpubkey}" || return $?
}
