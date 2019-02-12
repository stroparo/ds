# DS - Daily Shells Library

# Process management routines

pgr () { ps -ef | egrep -i "$1" | egrep -v "grep.*(${1})" ; }
psfu () { ps -fu "${UID:-$(id -u)}" -U "${UID:-$(id -u)}" ; }
psuser () { ps -ef | grep "^${USER}" ; }

psnoshells () {
  ps -ef \
    | grep -v bash \
    | grep -v zsh \
    | grep -v sshd \
    | egrep -i "$1" \
    | egrep -v "grep.*(${1})"
}
