# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Aliases

alias tpf='typeset -f'
alias tps='typeset'
alias xcd="alias | egrep \"'c?d \" | fgrep -v 'cd -'"
alias xgit="alias | grep 'git '"
alias xhome='[ -w ~/bin ] && chmod 740 ~/bin/*sh'

# Common:
alias cls='clear'
alias dfg='df -gP'
alias dfh='df -hP'
alias dums='du -ma | sort -n'
alias dumg='du -ma | sort -rn'
alias findd='find . -type d'
alias findf='find . -type f'
alias ya='youtube-dl -f "bestaudio"'
alias yd='youtube-dl'
alias yx='youtube-dl -x'

# Grep color:
if [[ $(grep --version 2>/dev/null) = *GNU* ]] ; then
    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
fi

# Ls:
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

# ##############################################################################
# Git:

alias gh='git diff HEAD'
alias gv='git mv'

# Replicate Oh My ZSH Git aliases in Bash:
if [ -n "${BASH_VERSION}" ] ; then
    alias ga='git add'
    alias gb='git branch'
    alias gc='git commit -v'
    alias gco='git checkout'
    alias gd='git diff'
    alias gdca='git diff --cached'
    alias gl='git pull'
    alias glog='git log --oneline --decorate --graph'
    alias gp='git push'
    alias grh='git reset HEAD'
    alias grhh='git reset HEAD --hard'
    alias gru='git reset --'
    alias gss='git status -s'
    alias gst='git status'
    alias gts='git tag -s'

    alias gr='git remote'
    alias gra='git remote add'
    alias grmv='git remote rename'
    alias grrm='git remote remove'
    alias grset='git remote set-url'
    alias grup='git remote update'
    alias grv='git remote -v'
fi

# ##############################################################################
# SysAdmin:

alias psfe='ps -fe'
alias psfens='ps -fe | grep -v bash | grep -v sshd'
alias psfu='ps -fu "${UID:-$(id -u)}" -U "${UID:-$(id -u)}"'
alias psfuns='ps -fu "${UID:-$(id -u)}" -U "${UID:-$(id -u)}" | grep -v bash | grep -v sshd'
alias psu='ps -ef|grep "${USER}"'
alias psuu='ps -u "${UID:-$(id -u)}" -U "${UID:-$(id -u)}" u'
alias psuunosh='ps -u "${UID:-$(id -u)}" -U "${UID:-$(id -u)}" u | grep -v bash | grep -v sshd'

# Aliases - admin - Linux & Cygwin:
if [[ "$(uname -a)" = *[Ll]inux* ]] || [[ "$(uname -a)" = *[Cc]ygwin* ]] ; then
    echo '' > /dev/null
# Aliases - admin - IBM AIX platform:
elif [[ $(uname) = *[Aa][Ii][Xx]* ]] ; then
    alias psft='ps -fT1'
    alias psftu='ps -fT1|awk "\$1 ~ /^$USER$/"'
fi

# ##############################################################################

