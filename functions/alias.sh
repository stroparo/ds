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
if which exa >/dev/null 2>&1 ; then alias e='exa -il'; alias ea='exa -ila'; fi
alias findd='find . -type d'
alias findf='find . -type f'
alias nhr='rm nohup.out'
alias nht='tail -9999f nohup.out'
alias vvvi='set -x; [[ $0 = *bash* ]] && set -b; set -o vi;export EDITOR=vim'
alias xcd="alias | egrep \"'c?d \" | fgrep -v 'cd -'"
alias xgit="alias | grep -w git"

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

if which ag >/dev/null 2>&1 ; then
    alias agp='ag --python'
    alias agr='ag --ruby'
    alias agasm='ag --asm'
    alias agbat='ag --batch'
    alias agcc='ag --cc'
    alias agclojure='ag --clojure'
    alias agcpp='ag --cpp'
    alias agcsharp='ag --csharp'
    alias agcss='ag --css'
    alias agdelphi='ag --delphi'
    alias agelixir='ag --elixir'
    alias agerlang='ag --erlang'
    alias aghtml='ag --html'
    alias agjs='ag --js'
    alias agmd='ag --md -i'
    alias agmk='ag --mk -i'
    alias agn='ag --line-numbers'
    alias agphp='ag --php'
    alias agrust='ag --rust'
    alias agshell='ag --shell'
    alias agsass='ag --sass'
    alias agscala='ag --scala'
    alias agsql='ag --sql'
    alias agvim='ag --vim'
    alias agyaml='ag --yaml'
    alias agxml='ag --xml'
fi

if which apt >/dev/null 2>&1 || which apt-get >/dev/null 2>&1 ; then
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
fi

if which git >/dev/null 2>&1 ; then

    alias bv='git branch -vv'
    alias bav='git branch -avv'
    alias gh='git diff HEAD'
    alias glggas='git log --graph --decorate --all --stat'
    alias glogas='git log --graph --decorate --all --stat --oneline'
    alias gv='git mv'

    # If no Oh-My-ZSH then load similar git aliases:
    if [ -z "${ZSH_THEME}" ] ; then
        alias ga='git add'
        alias gb='git branch'
        alias gc='git commit -v'
        alias gcb='git checkout -b'
        alias gcl='git clone --recursive'
        alias gco='git checkout'
        alias gd='git diff'
        alias gdca='git diff --cached'
        alias gf='git fetch'
        alias gl='git pull'
        alias glg='git log --stat'
        alias glgg='git log --graph'
        alias glog='git log --oneline --decorate --graph'
        alias gp='git push'
        alias grh='git reset HEAD'
        alias grhh='git reset HEAD --hard'
        alias gru='git reset --'
        alias gsps='git show --pretty=short --show-signature'
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
fi

if which youtube-dl >/dev/null 2>&1 ; then
    alias ydl='youtube-dl'
    alias ydlaudio='youtube-dl -f 140'
    alias ydlaudiobest='youtube-dl -f bestaudio'
    alias ydlx='youtube-dl -x'
fi

