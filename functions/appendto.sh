# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

appendto () {
    # Info: Append to variable (arg1), the given text (arg2).

    if [ -z "$(eval "echo \"\$${1}\"")" ] ; then
        eval "${1}=\"${2}\""
    else
        eval "${1}=\"\$${1}
${2}\""
    fi
}
