cdenforce () {
  mkdir -p "$1"
  cd "$1"
  [[ $PWD = */${1} ]]
}
