# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Executables and PATH

chmodshells ${DS_VERBOSE:+-v} -a "${DS_HOME}" | grep -v retained 1>&2
pathmunge -x "${DS_HOME}" "${DS_HOME}/bin" "${DS_HOME}/scripts"
pathmunge -a -v 'EEPATH' -x "${DS_HOME}"

