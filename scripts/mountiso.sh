# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# #############################################################################

mountiso () { sudo mount -o loop -t iso9660 "$@" ; }

mountiso "$@"
