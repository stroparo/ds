#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

[[ "$(uname -a)" = *[Ll]inux* ]] || exit
[ -e "$HOME/.local/share/fonts/Inconsolata for Powerline.otf" ] && exit

echo ${BASH_VERSION:+-e} '\n\n==> Installing powerline fonts...' 1>&2

wget https://github.com/powerline/fonts/archive/master.zip -O ~/powerline.zip
(cd ~ ; unzip powerline.zip)
~/fonts-master/install.sh && rm -rf ~/fonts-master ~/powerline.zip
