# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# PostgreSQL routines

alias pgc='sudo -iu postgres psql postgres'

pgr () {
    # Info: pgr is similar to pgrep

    ps -ef | egrep -i "$1" | egrep -v "grep.*(${1})"
}

pgralert () {
    # Info: Awaits found processes to finish then starts beeping until interrupted.

    while pgr "${1}" > /dev/null ; do sleep 1 ; done
    while true ; do echo '\a' ; sleep 8 ; done
}

supg () {
    # Info: Call psql via su - postgres, at the given port and user.
    # Syntax: [port=5432] [user=postgres]

    typeset port=${1:-5432}
    typeset user=${2:-postgres}
    shift 2

    sudo su - postgres -c "psql -p ${port} -U ${user} $@"
}
