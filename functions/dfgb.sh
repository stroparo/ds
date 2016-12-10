# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

dfgb () {
    # Info: Display free disk space in GB.

    typeset dfdir="${1:-.}"
    typeset freegb

    [ -d "${dfdir}" ] || return 10

    freegb=$(df -gP "${dfdir}" | tail -n +2 | tail -n 1 | awk '{print $4}' | cut -d'.' -f1) \
    || return 20

    echo "${freegb}"
}
