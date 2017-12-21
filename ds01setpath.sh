# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# #############################################################################
# Executables and PATH

# STRONGLY RECOMMENDED munging the PATH before anything else:
pathmunge -x "${DS_HOME}"

for dir in $(ls -1 -d "$DS_HOME"/*/ \
  | grep -E -v '(functions|templates)/$' \
  | sed -e 's#//*$##')
do
  pathmunge -x "$dir"
done

pathmunge -a -v 'EEPATH' -x "${DS_HOME}"

chmodshells ${DS_VERBOSE:+-v} -a "${DS_HOME}"
true
