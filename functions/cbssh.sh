# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

cbssh () {
    # Info: Copies ~/.ssh/id_rsa.pub contents to the clipboard via the DS cb script
    cb < "${HOME}/.ssh/id_rsa.pub"
}
