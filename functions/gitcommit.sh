# Daily Shells Stroparo

gci () { typeset msg="$1"; shift; git commit -m "$msg" "$@" ; }
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

gca () { gci "$@" --amend ; }
gcaarr () { gciarr "$@" --amend ; }
gcacom () { gcicom "$@" --amend ; }
gcafix () { gcifix "$@" --amend ; }
gcafmt () { gcifmt "$@" --amend ; }
gcamv () { gcimv "$@" --amend ; }
gcarf () { gcirf "$@" --amend ; }
gcarn () { gcirn "$@" --amend ; }
gcarm  () { gcirm "$@" --amend ; }
gcatodo () { gcitodo "$@" --amend ; }
gcaup () { gciup "$@" --amend ; }
gcawp () { gciwp "$@" --amend ; }

gpa () { gci "$@" --amend ; git push -f origin HEAD ; }
gpaarr () { gciarr "$@" --amend ; git push -f origin HEAD ; }
gpacom () { gcicom "$@" --amend ; git push -f origin HEAD ; }
gpafix () { gcifix "$@" --amend ; git push -f origin HEAD ; }
gpafmt () { gcifmt "$@" --amend ; git push -f origin HEAD ; }
gpamv () { gcimv "$@" --amend ; git push -f origin HEAD ; }
gparf () { gcirf "$@" --amend ; git push -f origin HEAD ; }
gparn () { gcirn "$@" --amend ; git push -f origin HEAD ; }
gparm  () { gcirm "$@" --amend ; git push -f origin HEAD ; }
gpatodo () { gcitodo "$@" --amend ; git push -f origin HEAD ; }
gpaup () { gciup "$@" --amend ; git push -f origin HEAD ; }
gpawp () { gciwp "$@" --amend ; git push -f origin HEAD ; }

gpi () { gci "$@" ; git push origin HEAD ; }
gpiarr () { gciarr "$@" ; git push origin HEAD ; }
gpicom () { gcicom "$@" ; git push origin HEAD ; }
gpifix () { gcifix "$@" ; git push origin HEAD ; }
gpifmt () { gcifmt "$@" ; git push origin HEAD ; }
gpimv () { gcimv "$@" ; git push origin HEAD ; }
gpirf () { gcirf "$@" ; git push origin HEAD ; }
gpirn () { gcirn "$@" ; git push origin HEAD ; }
gpirm  () { gcirm "$@" ; git push origin HEAD ; }
gpitodo () { gcitodo "$@" ; git push origin HEAD ; }
gpiup () { gciup "$@" ; git push origin HEAD ; }
gpiwp () { gciwp "$@" ; git push origin HEAD ; }
