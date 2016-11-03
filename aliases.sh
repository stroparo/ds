
# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Aliases

alias cls='clear'
alias dfg='df -gP'
alias dfh='df -hP'
alias dums='du -ma | sort -n'
alias dumg='du -ma | sort -rn'
alias findd='find . -type d'
alias findf='find . -type f'
alias nhr='rm nohup.out'
alias nht='tail -9999f nohup.out'
alias tpf='typeset -f'
alias tps='typeset'
alias xcd="alias | egrep \"'c?d \" | fgrep -v 'cd -'"
alias xgit="alias | grep 'git '"

# ##############################################################################
# Apps

alias pgc='sudo -iu postgres psql postgres'
alias sb='subl'
alias ya='youtube-dl -f mp3'
alias yabest='youtube-dl -f bestaudio'
alias yd='youtube-dl'
alias yx='youtube-dl -x'

# ##############################################################################
# APT, dpkg etc.

alias apd='sudo aptitude update && sudo aptitude'
alias apdnoup='sudo aptitude'
alias apti='sudo aptitude update && sudo aptitude install -y'
alias apts='apt-cache search'
alias aptshow='apt-cache show'
alias aptshowpkg='apt-cache showpkg'
alias dpkgl='dpkg -L'
alias dpkgs='dpkg -s'
alias dpkgsel='dpkg --get-selections | egrep -i'
alias upalt='sudo update-alternatives'

# ##############################################################################
# Git

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
# Grep (+ Ag ...) and ls (+ Exa ...)

alias agas='ag --asm'
alias agbat='ag --batch'
alias agcc='ag --cc'
alias agcl='ag --clojure'
alias agcpp='ag --cpp'
alias agcs='ag --csharp'
alias agcss='ag --css'
alias agd='ag --delphi'
alias agel='ag --elixir'
alias ager='ag --erlang'
alias agh='ag --html'
alias agj='ag --js'
alias agm='ag --md -i'
alias agmk='ag --mk -i'
alias agp='ag --php'
alias agr='ag --ruby'
alias agrs='ag --rust'
alias ags='ag --shell'
alias agsa='ag --sass'
alias agsc='ag --scala'
alias agsq='ag --sql'
alias agv='ag --vim'
alias agy='ag --python'
alias agym='ag --yaml'
alias agx='ag --xml'

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
# SysAdmin

alias edhosts='sudo vi /etc/hosts'
alias edkeys='mkdir ~/.ssh 2>/dev/null ; vi ~/.ssh/authorized_keys'

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

