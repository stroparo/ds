# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Executables and PATH

# STRONGLY RECOMMENDED munging the PATH before anything else:
pathmunge -x "${DS_HOME}" "$(ls -1 -d "$DS_HOME"/*/ | grep -v 'functions/$')"
pathmunge -a -v 'EEPATH' -x "${DS_HOME}"

chmodshells ${DS_VERBOSE:+-v} -a "${DS_HOME}" | grep -v retained 1>&2
true
