# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Desktop routines

cbf () { cb < "$1"; } # argument to clipboard
cbssh () { cb < "${HOME}/.ssh/id_rsa.pub" ; } # ~/.ssh/id_rsa.pub toclipboard
