# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

callapi () {
  typeset x="$1"; typeset url="$2"; typeset token="$3"
  curl -s -X ${x:-GET} ${token:+-H "PRIVATE-TOKEN: $token"} "$url"
}
