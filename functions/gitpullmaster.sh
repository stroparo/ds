gitpullmaster () {
  echo
  for repo in "$@" ; do
    if [ -d "$repo" ] ; then
      (
        cd "$repo"
        if [ ! -d "$repo/.git" ] ; then continue ; fi
        echo
        echo "==> $(basename "$repo")"
        pwd
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
