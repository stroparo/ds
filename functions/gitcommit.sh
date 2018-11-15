# Daily Shells Stroparo


# Oneliners

gci () { typeset msg="$1"; shift; git commit -m "$@" ; }
gciarr () { typeset msg="$1"; shift; git commit -m "Rearrange $msg" "$@" ; }
gcicom () { typeset msg="$1"; shift; git commit -m "Comment $msg" "$@" ; }
gcifix () { typeset msg="$1"; shift; git commit -m "Fix $msg" "$@" ; }
gcifmt () { typeset msg="$1"; shift; git commit -m "Format $msg" "$@" ; }
gcimv () { typeset msg="$1"; shift; git commit -m "Move $msg" "$@" ; }
gcirf () { typeset msg="$1"; shift; git commit -m "Refactor $msg" "$@" ; }
gcirn () { typeset msg="$1"; shift; git commit -m "Rename $msg" "$@" ; }
gcirm  () { typeset msg="$1"; shift; git commit -m "Remove $msg" "$@" ; }
gcitodo () { typeset msg="$1"; shift; git commit -m "TODO add $msg" "$@" ; }
gciup () { typeset msg="$1"; shift; git commit -m "Update $msg" "$@" ; }
gciwp () { typeset msg="$1"; shift; git commit -m "Work in progress $msg" "$@" ; }
