# Daily Shells Library
# More instructions and licensing at:
# https://github.com/stroparo/ds

# #############################################################################
# Portability testing routines

_has_gnu () {
  find --version 2> /dev/null | grep -i -q 'gnu'
}
