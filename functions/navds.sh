dbak    () { d "${DS_ENV_BAK}" ; }
dlog    () { cd "${DS_ENV_LOG}" && ls -AFlrt ; }
dlast   () { cd "$(ls -1d */|sort|tail -n 1)" && ls -AFlrt ; }
ltoday  () { cd "${DS_ENV_LOG}" && (ls -AFlrt | grep "$(date +"%b %d")") ; }
ups     () { d "${UPS:-$HOME/upstream}" "$@" ; }
upsalt  () { d "${UPS:-$HOME/upstream}_alt" "$@" ; }
v       () { cd "${DEV:-$HOME/workspace}" ; d "$@" ; }
