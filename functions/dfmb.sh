# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

dfmb () {
    # Info: Display free disk space in MB.

    typeset dfdir="${1:-.}"
    typeset freespace

    [ -d "${dfdir}" ] || return 10

    freespace=$(df -mP "${dfdir}" | tail -n +2 | tail -n 1 | awk '{print $4}' | cut -d'.' -f1) \
      || return 20

    echo "${freespace}"
}
