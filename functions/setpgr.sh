# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# pgr is similar to pgrep

pgr () { ps -ef | egrep -i "$1" | egrep -v "grep.*(${1})" ; }

pgralert () {
    # Info: Awaits found processes to finish then starts beeping until interrupted.
    while pgr "${1}" > /dev/null ; do sleep 1 ; done
    while true ; do echo '\a' ; sleep 8 ; done
}
