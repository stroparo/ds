# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

alias edetchosts='sudo vi /etc/hosts'
alias edsshkeys='mkdir ~/.ssh 2>/dev/null ; vi ~/.ssh/authorized_keys'

alias psfe='ps -fe'
alias psfens='ps -fe | grep -v bash | grep -v sshd'
alias psfu='ps -fu "${UID:-$(id -u)}" -U "${UID:-$(id -u)}"'
alias psfuns='ps -fu "${UID:-$(id -u)}" -U "${UID:-$(id -u)}" | grep -v bash | grep -v sshd'
alias psu='ps -ef|grep "${USER}"'
alias psuu='ps -u "${UID:-$(id -u)}" -U "${UID:-$(id -u)}" u'
alias psuunosh='ps -u "${UID:-$(id -u)}" -U "${UID:-$(id -u)}" u | grep -v bash | grep -v sshd'

# Aliases - admin - IBM AIX platform:
if [[ $(uname) = *[Aa][Ii][Xx]* ]] ; then

    alias psft='ps -fT1'
    alias psftu='ps -fT1|awk "\$1 ~ /^$USER$/"'

# Aliases - admin - Linux & Cygwin:
# elif [[ "$(uname -a)" = *[Ll]inux* ]] || [[ "$(uname -a)" = *[Cc]ygwin* ]] ; then

#     ...

fi
