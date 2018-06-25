type take >/dev/null 2>&1 && return

take () {
  mkdir "$1" || return "$?"
  cd "$1"
}
