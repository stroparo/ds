#!/usr/bin/env bash

getcacerts () {
  curl -L "http://curl.haxx.se/ca/cacert.pem" \
    | awk '
        split_after==1 {n++;split_after=0}
        /-----END CERTIFICATE-----/ {split_after=1}
        {print > "cert" n ".pem"}'
  c_rehash || sudo c_rehash
}

getcacerts
