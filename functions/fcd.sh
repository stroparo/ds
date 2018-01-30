fcd () {
  typeset searchexpr
  typeset searchterm="$1"

	searchexpr=$(ruby -e "print '$searchterm'.gsub(/\s+/,'').split('').join('.*')")

	if [ $# -eq 0 ]; then
		echo "fcd: traverses the current dirtree and cd to the first match"
		echo "You need an argument"
	else
    echo "fcd: Searching..."
    founddir=`find "$PWD" -type d \
      | egrep "${PWD}.*/$searchexpr" \
      | sort \
      | head -n 1`
    if [ -n "$founddir" ] ; then
      cd "$founddir"
    fi
	fi
}
