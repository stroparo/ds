gitpullmaster () {
  for repo in "$@" ; do
    if [ -d "$repo" ] ; then
      (
        cd "$repo"
        pwd
        git pull origin master
        # TODO add push to mirror remote (when it exists)
        git branch -vv
        echo "git status at '${PWD}':"
        git status -s
        echo
      )
    fi
  done
}
