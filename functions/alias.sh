# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Aliases aliases
alias xcd="alias | egrep \"'c?d \" | fgrep -v 'cd -'"
alias xgit="alias | grep 'git '"

alias cls='clear'
alias dfg='df -gP'
alias dfh='df -hP'
alias dums='du -ma | sort -n'
alias dumg='du -ma | sort -rn'
alias findd='find . -type d'
alias findf='find . -type f'
alias sb='subl'
alias tpf='typeset -f'
alias tps='typeset'
alias ya='youtube-dl -f 140'
alias yabest='youtube-dl -f bestaudio'
alias yd='youtube-dl'
alias yx='youtube-dl -x'

# ##############################################################################
# Grep color
if [[ $(grep --version 2>/dev/null) = *GNU* ]] ; then
    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
fi

# ##############################################################################
# No hang up (nohup)
alias nhr='rm nohup.out'
alias nht='tail -9999f nohup.out'

# ##############################################################################
# Ls etcetera

if [[ $(ls --version 2>/dev/null) = *GNU* ]] ; then
    alias ls='ls --color=auto'
    alias l='ls -Fhil'
    alias ll='ls -FhilA'
    alias lt='ls -Fhilrt'
else
    alias l='ls -Fl'
    alias ll='ls -AFl'
    alias lt='ls -Flrt'
fi

if which exa >/dev/null 2>&1 ; then
    alias e='exa -il'
    alias ea='exa -ila'
fi

# ##############################################################################

