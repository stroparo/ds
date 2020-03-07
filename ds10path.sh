# DS - Daily Shells Library

# #############################################################################
# Executables and PATH

ignore_expr="$DS_HOME/(conf|functions|templates)"

# STRONGLY RECOMMENDED munging the PATH before anything else:
pathmunge -x "${DS_HOME}" $(_dsgetscriptsdirs)

pathmunge -a -i -v 'EEPATH' -x "${DS_HOME}"

true
