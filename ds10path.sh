# DS - Daily Shells Library

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

if [[ $DS_VERBOSE = vv ]] ; then
  chmodshells -a -v "${DS_HOME}"
else
  chmodshells -a "${DS_HOME}"
fi
true
