gitpullmaster () {

  typeset header_msg
  if [ "$1" = '-h' ] && [ -n "$2" ] ; then
    header_msg="$2" ; shift 2
  fi

  echo
  for repo in "$@" ; do
    repo=${repo%/.git}
    if [ -d "${repo}" ] ; then
      (
        cd "${repo}"
        if [ ! -d "${repo}/.git" ] ; then continue ; fi
        echo
        echo "==> $(basename "${repo}") ($(pwd))"
        echo
        git pull origin master
        git branch -vv
        echo "git status at '${PWD}':"
        git status -s
        echo
      )
    fi
  done
}
