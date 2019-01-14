#!/usr/bin/env bash

podcastprep () {
    # Dep: mp3splt (http://mp3splt.sourceforge.net/)
    # Info: put each mp3 in the current dir into its own directory and split it
    # Syntax: [directory:-current]

  typeset inbasename
  typeset indir="${1:-.}"
  typeset infiles
  typeset outdir
  typeset outfilename
  typeset splitexpr

  cd "$indir"
  infiles="$(ls -1 ./*.mp3)"

  if [ -z "$infiles" ] ; then
    echo "SKIP: No input files (ls -1 ./*.mp3)." 1>&2
    return
  fi

  while read infile ; do

    echo; echo

    inbasename="${infile##*/}"
    outdir="${infile%.mp3}"

    [ -f "$infile" ] \
      && mkdir "${outdir}" \
      && [ -d "${outdir}" ] \
      && echo ${BASH_VERSION:+-e} "==> $inbasename" \
      && mv -v "$infile" "${outdir}/${inbasename}" \
      || continue

    if (uname -a | egrep -i -q "cygwin|mingw|msys|win32|windows") ; then
      outfilename="$(cygpath -w "${outdir}/${inbasename}")"
      splitexpr="3.0>2.0"
    else
      outfilename="${outdir}/${inbasename}"
      splitexpr="2.0"
    fi

    if mp3splt -a -t "$splitexpr" "$outfilename"; then
      rm -f -v "${outdir}/${inbasename}"
    else
      mv -v "${outdir}/${inbasename}" "${indir}/"
    fi

  done <<EOF
$infiles
EOF
}

podcastprep "$@"
