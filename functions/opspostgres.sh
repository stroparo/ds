# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# PostgreSQL routines

pglocal () { psql -h '127.0.0.1' "$@" ; }
pgpg () { sudo -iu postgres psql postgres ; }

pgcreateuser () {

    typeset pguser=${1}
    typeset database=${2:-template1}

    if [ "$pguser" = 'user' ] ; then
        echo "FATAL: Your username 'user' is a postgresql reserved word."
        exit 1
    fi

    sudo su - postgres -c "psql -p 5432 -U postgres -d ${database}" <<EOF
CREATE ROLE ${pguser} WITH LOGIN CREATEROLE;
ALTER ROLE ${pguser} WITH PASSWORD '${pguser}';

GRANT ALL ON DATABASE ${database} TO ${pguser};

ALTER DEFAULT PRIVILEGES
    -- FOR ROLE ${pguser}
    IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES
    TO ${pguser}
    ;

ALTER DEFAULT PRIVILEGES
    IN SCHEMA public
    GRANT SELECT, USAGE ON SEQUENCES
    TO ${pguser}
    ;

\q
EOF
}

pgsu () {
    # Info: Call psql via su - postgres, at the given port and user.
    # Syntax: [port=5432] [user=postgres]

    typeset port=${1:-5432}
    typeset user=${2:-postgres}
    shift 2

    sudo su - postgres -c "psql -p ${port} -U ${user} $@"
}
