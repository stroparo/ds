# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Aliases

alias xcd="alias | egrep \"'c?d \""
alias xhome='cd ~/bin && chmod 740 *sh'

# DS change directory aliases:
alias cdbak='d "${BACKUP_DIRECTORY}" -A'
alias cde='d "${DS_ENV}" -A'
alias cdl='cd "${DS_ENV_LOG}" && (ls -AFlrt | tail -n 64)'
alias cdll='d "${DS_ENV_LOG}" -Art'
alias cdlgt='cd "${DS_ENV_LOG}" && (ls -AFlrt | grep "$(date +"%b %d")")'
alias cdlt='cd "${DS_ENV_LOG}" && d "$(date "+%Y%m%d")" -ARrt'
alias t='d "${TEMP_DIRECTORY}" -A'

# Aliases - admin:
alias psfe='ps -fe'
alias psfens='ps -fe | grep -v bash | grep -v sshd'
alias psfu='ps -fu "${UID:-$(id -u)}" -U "${UID:-$(id -u)}"'
alias psfuns='ps -fu "${UID:-$(id -u)}" -U "${UID:-$(id -u)}" | grep -v bash | grep -v sshd'
alias psu='ps -ef|grep "${USER}"'
alias psuu='ps -u "${UID:-$(id -u)}" -U "${UID:-$(id -u)}" u'
alias psuuns='ps -u "${UID:-$(id -u)}" -U "${UID:-$(id -u)}" u | grep -v bash | grep -v sshd'

# Aliases - admin - Linux & Cygwin:
if [[ "$(uname -a)" = *inux* ]] || [[ "$(uname -a)" = *ygwin* ]] ; then
    alias cls='clear'
# Aliases - admin - IBM AIX platform:
elif [[ $(uname) = *AIX* ]] ; then
    alias psft='ps -fT1'
    alias psftu='ps -fT1|awk "\$1 ~ /^$USER$/"'
fi

# Aliases - apps:
alias dfg='df -gP'
alias dfh='df -hP'
alias dums='du -ma | sort -rn'
alias findd='find . -type d'
alias findf='find . -type f'

# Aliases - apps - GNU vs non-GNU:
if [[ $(grep --version 2>/dev/null) = *GNU* ]] ; then
    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
fi

if [[ $(ls --version 2>/dev/null) = *GNU* ]] ; then
    alias ls='ls --color=auto'
    alias l='ls -Flhi'
    alias ll='ls -AFlhi'
    alias lt='ls -Flrthi'
else
    alias l='ls -Fl'
    alias ll='ls -AFl'
    alias lt='ls -Flrt'
fi

