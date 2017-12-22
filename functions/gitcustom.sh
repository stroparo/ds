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

gra () { gitr.sh add -A ; }
grap () { gitr.sh -p add -A ; }
grapv () { gitr.sh -p -v add -A ; }
grci () { gitr.sh commit -m "$@" ; }

# branch - display current branch
grbc () { gitr.sh branch | egrep '^(==|[*])' ; }

# diff - cached index vs argument (git default ie HEAD)
grdca () { gitr.sh diff --cached "$@" ; }

# pull
grl () { gitr.sh l ; }
grlp () { gitr.sh -p l ; }
grlpv () { gitr.sh -p -v l ; }

# gitr push
grp () { gitr.sh p ; }
grpp () { gitr.sh -p p ; }
grppv () { gitr.sh -p -v p ; }

# gitr status -s
grs () { gitr.sh ss ; }
grsp () { gitr.sh -p ss ; }
grspv () { gitr.sh -p -v ss ; }
