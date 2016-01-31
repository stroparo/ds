# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# OS tests

_is_cygwin () { [[ "$(uname -a)" = *ygwin* ]] ; }
_is_debian () { [[ "$(uname -a)" = *[Db]ebian* ]] ; }
_is_linux () { [[ "$(uname -a)" = *[Ll]inux* ]] ; }
_is_ubuntu () { [[ "$(uname -a)" = *[Uu]buntu* ]] ; }
