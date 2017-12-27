# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

topuser () {
    # Info: Outputs top info for user processes (topas for AIX).
    if [[ $(uname -a) = *[Aa][Ii][Xx]* ]] ; then
        topas -U "${USER}" -P
    else
        top -U "${UID:-$(id -u)}"
    fi
}

