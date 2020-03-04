# Daily Shells Stroparo

gci () { typeset msg="$1"; shift; git commit -m "$msg" "$@" ; }
gciadd () { typeset msg="$1"; shift; git commit -m "Add $msg" "$@" ; }
gciarr () { typeset msg="$1"; shift; git commit -m "Rearrange $msg" "$@" ; }
gcicom () { typeset msg="$1"; shift; git commit -m "Comment $msg" "$@" ; }
gcifix () { typeset msg="$1"; shift; git commit -m "Fix $msg" "$@" ; }
gcifmt () { typeset msg="$1"; shift; git commit -m "Format $msg" "$@" ; }
gcimv () { typeset msg="$1"; shift; git commit -m "Move $msg" "$@" ; }
gcirf () { typeset msg="$1"; shift; git commit -m "Refactor $msg" "$@" ; }
gcirn () { typeset msg="$1"; shift; git commit -m "Rename $msg" "$@" ; }
gcirm  () { typeset msg="$1"; shift; git commit -m "Remove $msg" "$@" ; }
gcitodo () { typeset msg="$1"; shift; git commit -m "TODO $msg" "$@" ; }
gciup () { typeset msg="$1"; shift; git commit -m "Update $msg" "$@" ; }
gciwp () { typeset msg="$1"; shift; git commit -m "Work in progress $msg" "$@" ; }

gpi () { gci "$@" ; gpa ; }
gpiarr () { gciarr "$@" ; gpa ; }
gpicom () { gcicom "$@" ; gpa ; }
gpifix () { gcifix "$@" ; gpa ; }
gpifmt () { gcifmt "$@" ; gpa ; }
gpimv () { gcimv "$@" ; gpa ; }
gpirf () { gcirf "$@" ; gpa ; }
gpirn () { gcirn "$@" ; gpa ; }
gpirm  () { gcirm "$@" ; gpa ; }
gpitodo () { gcitodo "$@" ; gpa ; }
gpiup () { gciup "$@" ; gpa ; }
gpiwp () { gciwp "$@" ; gpa ; }


g1 () {

  typeset message="$1" ; shift

  echo
  echo "Status:"
  git status -s

  echo
  echo "Diff:"
  git diff

  echo
  if userconfirm "Commit and push?" ; then

    while [ -z "$message" ]; do
      echo "Enter commit message:"
      read message
    done

    git add -A "$@"
    git commit -m "$message"

    gpa HEAD
    gpa HEAD
  fi
}


gpa () {
  # Info: Git push the given branch to all remotes (branch defaults to HEAD)
  # Syn: [branch=HEAD]

  typeset branch="${1:-HEAD}"
  typeset remote

  echo
  echo "gpa: INFO: Checking out the '${branch}' branch..."
  git checkout "${branch}"

  for remote in $(git remote) ; do
    echo
    echo "gpa: INFO: Pushing to remote '${remote}'s branch '${branch}'..."
    git push "${remote}" "${branch}"
  done
}

