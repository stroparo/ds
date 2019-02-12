ups     () { d "${UPS:-$HOME/upstream}" "$@" ; }
upsalt  () { d "${UPS:-$HOME/upstream}_alt" "$@" ; }
v       () { cd "${DEV:-$HOME/workspace}" ; d "$@" ; }
