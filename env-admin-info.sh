# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Admin & ops informational functions

# Function dfgb - displays free disk space in GB.
unset dfgb
dfgb () {
    [ -d "$1" ] || return 1
    df -gP "$1" | fgrep "$1" | awk '{print $4}' | cut -d. -f1
}

# Function dpkgstat: View installation status of given package names.
# Deps: bash and debian based dpkg command.
# Output: dpkg -s output filtered by '^Package:|^Status:'
# Syntax: {pkg1} {pkg2} ... {pkgN}
unset dpkgstat
dpkgstat () {
    typeset usage='Syntax: ${0} {pkg1} {pkg2} ... {pkgN}'

    [ "${#}" -lt 1 ] && echo "${usage}" && return 1

    dpkg -s "$@" | \
    awk '
        /^Package:/ { pkg = $0; }
        /^Status:/ {
            stat = $0; printf("%-32s%s\n", pkg, stat);
        }'
}

# Function pgr - pgrep emulator.
# Syntax: [egrep-pattern]
unset pgr
pgr () {
    ps -ef | egrep -i "${1}" | egrep -v "grep.*(${1})"
}

# Function topu - top user processes, or topas when working on AIX.
unset topu
topu () {
    if [[ $(uname) = *AIX* ]] ; then
        topas -U "${USER}" -P
    else
        top -U "${UID:-$(id -u)}"
    fi
}
