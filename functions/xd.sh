# Based on the up function from https://github.com/PogiNate/dots/commit/e13a056361f2b559d501eb19c6079b05e4510e64#diff-033f192d54c92104ab10fd785a61f24cR17

_xd () {
	typeset rx updir
	rx=$(ruby -e "print '$1'.gsub(/\s+/,'').split('').join('.*?')")
	updir=`echo $PWD | ruby -e "print STDIN.read.sub(/(.*\/${rx}[^\/]*\/).*/i,'\1')"`
	echo -n "$updir"
}

xd () {
	if [ $# -eq 0 ]; then
		echo "xd: traverses up the current working directory to first match and cds to it"
		echo "You need an argument"
	else
		cd $(_xd "$@")
	fi
}

