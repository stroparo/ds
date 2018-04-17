# DS - Daily Shells Library

# #############################################################################
# Ops routines

pgr () { ps -ef | egrep -i "$1" | egrep -v "grep.*(${1})" ; }
psfu () { ps -fu "${UID:-$(id -u)}" -U "${UID:-$(id -u)}" ; }
psnoshells () { ps -ef | grep -v bash | grep -v zsh | grep -v sshd ; }
psuser () { ps -ef | grep "^${USER}" ; }
