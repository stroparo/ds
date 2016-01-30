# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Mathematical functions

# Syntax: sep field files...
getmax () {

    typeset sep="${1}"
    typeset field="${2}"
    shift 2

    awk -F"${sep}" -vfield="${field}" '
        BEGIN {
            max = 0;
        }

        {
            if (max < $field) max = $field;
        }

        END {
            print max;
        }
    ' "$@"

}

# Syntax: sep field files...
getmin () {

    typeset sep="${1}"
    typeset field="${2}"
    shift 2

    awk -F"${sep}" -vfield="${field}" '
        BEGIN {
            min = 2147483648;
        }

        {
            if (min > $field) min = $field;
        }

        END {
            print min;
        }
    ' "$@"

}

# Syntax: sep field files...
getsum () {

    typeset sep="${1}"
    typeset field="${2}"
    shift 2

    awk -F"${sep}" -vfield="${field}" '
        BEGIN {
            sum = 0;
        }

        {
            sum += $field;
        }

        END {
            print sum;
        }
    ' "$@"

}

