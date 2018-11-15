#!/usr/bin/env bash

getcacerts () {
  for certdir in "$@" ; do
    (
      mkdir /usr/ssl/certs >/dev/null 2>&1 \
        || sudo mkdir /usr/ssl/certs >/dev/null 2>&1
      cd /usr/ssl/certs
      curl -LSfs "http://curl.haxx.se/ca/cacert.pem" \
        | awk '
            split_after==1 {n++;split_after=0}
            /-----END CERTIFICATE-----/ {split_after=1}
            {print > "cert" n ".pem"}'
    )
    c_rehash "$certdir" || sudo c_rehash
  done
}

if [ $# -eq 0 ] ; then
  getcacerts "/usr/ssl/certs"
else
  getcacerts "$@"
fi
