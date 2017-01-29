# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

alias psef='ps -ef'
alias psefnoshells='ps -ef | grep -v bash | grep -v sshd'
alias psefuser='ps -ef|grep "${USER}"'
alias psfu='ps -fu "${UID:-$(id -u)}" -U "${UID:-$(id -u)}"'
alias psfunoshells='ps -fu "${UID:-$(id -u)}" -U "${UID:-$(id -u)}" | grep -v bash | grep -v sshd'

# IBM AIX platform:
if [[ $(uname) = *[Aa][Ii][Xx]* ]] ; then
    alias psft='ps -fT1'
    alias psftu='ps -fT1|awk "\$1 ~ /^$USER$/"'
fi
