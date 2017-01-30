# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

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
