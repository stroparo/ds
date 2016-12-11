# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Control scripts - wrapper functions

cta () { sudo "/etc/init.d/apache${2:-2}"   "${1:-restart}" ; }
ctlamp () { "${LAMPHOME}/ctlscript.sh"      "${1:-restart}" ; }
ctpg () { sudo "/etc/init.d/postgresql${2}" "${1:-restart}" ; }
