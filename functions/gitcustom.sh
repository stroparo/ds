# Author: Cristian Stroparo

add () { git add -A "$@" ; git status -s ; }
addd () { git add -A "$@" ; git status -s ; git diff --cached ; }
gci () { git commit -m "$@" ; }
gciarr () { git commit -m "Rearrange $1" ; }
gcicom () { git commit -m "Comment $1" ; }
gcifix () { git commit -m "Fix $1" ; }
gcifmt () { git commit -m "Format $1" ; }
gcirf () { git commit -m "Refactor $1" ; }
gcirn () { git commit -m "Rename $1" ; }
gcirm  () { git commit -m "Removed $1" ; }
gcitodo () { git commit -m "TODO added $1" ; }
gciup () { git commit -m "Updated $1" ; }
gciwp () { git commit -m "Work in progress $1" ; }

# #############################################################################
# gitr DS script wrappers:

gtraa () { gitr.sh add -A ; }
gtrbvc () { gitr.sh branch -v "$@" | egrep '^(==|[*])' ; }
gtrci () { gitr.sh commit -m "$@" ; }
gtrdca () { gitr.sh diff --cached "$@" ; }

# pull
gtrl () { gitr.sh l ; }
gtrlp () { gitr.sh -p l ; }
gtrlpv () { gitr.sh -p -v l ; }

# gitr push
gtrp () { gitr.sh p ; }
gtrpp () { gitr.sh -p p ; }
gtrppv () { gitr.sh -p -v p ; }

# gitr status -s
gtrs () { gitr.sh ss ; }
gtrsp () { gitr.sh -p ss ; }
gtrspv () { gitr.sh -p -v ss ; }
