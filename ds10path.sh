# DS - Daily Shells Library

# #############################################################################
# Executables and PATH

ignore_expr="$DS_HOME/(conf|functions|templates)"

# STRONGLY RECOMMENDED munging the PATH before anything else:
pathmunge -x "${DS_HOME}"

if ls -d "$DS_HOME"/*/ >/dev/null 2>&1 ; then
  pathmunge -x $(_dsgetscriptsdirs)
fi

pathmunge -a -i -v 'EEPATH' -x "${DS_HOME}"

if ${DS_CHMODSCRIPTS:-true} ; then
  if [[ $DS_VERBOSE = vv ]] ; then
    CHMODSCRIPTS_OPTIONS="-v"
  fi
  chmodscripts -a ${CHMODSCRIPTS_OPTIONS} $(_dsgetscriptsdirs)
fi

true
