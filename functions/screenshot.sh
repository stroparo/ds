# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

screenshot () {
    # Info: Take a screenshot of the desktop, by default after 5 seconds.
    # Syntax: [secondsToWait=5]

    typeset date_ymd_hms=$(date '+%Y%m%d-%H%M%S')

    sleep "${1:-5}"
    import -window root "${HOME}/screenshot-${date_ymd_hms}.png"
}
