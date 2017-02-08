# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

alias gbv='git branch -v'
alias gh='git diff HEAD'
alias glggas='git log --graph --decorate --all --stat'
alias glogas='git log --graph --decorate --all --stat --oneline'
alias gv='git mv'

# If no Oh-My-ZSH then load similar git aliases:
if [ -z "${ZSH_THEME}" ] ; then
    alias ga='git add'
    alias gb='git branch'
    alias gc='git commit -v'
    alias gcl='git clone --recursive'
    alias gco='git checkout'
    alias gd='git diff'
    alias gdca='git diff --cached'
    alias gl='git pull'
    alias glg='git log --stat'
    alias glgg='git log --graph'
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

