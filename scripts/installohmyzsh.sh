#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

if ! which zsh >/dev/null ; then
  echo "WARN: zsh is not installed. Nothing done." 1>&2
  exit
fi

echo ${BASH_VERSION:+-e} '\n==> Setting up oh-my-zsh...' 1>&2

if [ ! -d "${HOME}/.oh-my-zsh" ] ; then
  sh -c "$(curl -LSfs https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

echo ${BASH_VERSION:+-e} '\n==> Setting up zsh-syntax-highlighting plugin...' 1>&2

git clone 'https://github.com/zsh-users/zsh-syntax-highlighting.git' ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
if [ -f ~/.zshrc ] && ! grep -q 'plugins=.*zsh-syntax-highlighting' ~/.zshrc ; then
  sed -i -e 's/\(plugins=(.*\))/\1 zsh-syntax-highlighting)/' ~/.zshrc
fi
