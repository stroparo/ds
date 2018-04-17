# DS - Daily Shells Library

cbssh () {
    # Info: Copies ~/.ssh/id_rsa.pub contents to the clipboard via the DS cb script
    cb < "${HOME}/.ssh/id_rsa.pub"
}
