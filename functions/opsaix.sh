if [[ $(uname) = *[Aa][Ii][Xx]* ]] ; then
  psft () { ps -fT1 ; }
  psftu () { ps -fT1 | awk "\$1 ~ /^$USER$/" ; }
fi
