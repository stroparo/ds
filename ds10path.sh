# DS - Daily Shells Library

# #############################################################################
# Executables and PATH

ignore_expr="$DS_HOME/(conf|functions|templates)"

# STRONGLY RECOMMENDED munging the PATH before anything else:
pathmunge -x "${DS_HOME}"

if ls -d "$DS_HOME"/*/ >/dev/null 2>&1 ; then
  for dir in $(_dsgetscriptsdirs) ; do
    pathmunge -x "$dir"
  done
fi

pathmunge -a -i -v 'EEPATH' -x "${DS_HOME}"

if [[ $DS_VERBOSE = vv ]] ; then
  chmodscripts -a -v $(_dsgetscriptsdirs)
else
  chmodscripts -a $(_dsgetscriptsdirs)
fi
true
