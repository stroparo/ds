# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Admin APT (aptitude & apt-get) functions

# Function ckapt
# Purpose:
#   Check if inside an APT environment
unset ckapt
ckapt () {
    if ! which apt > /dev/null && ! which apt-get > /dev/null ; then
        echo "Not in an APT environment.." 1>&2
        return 1
    fi
    return 0
}

# Function ckaptitude
# Purpose:
#   Checks and installs aptitude if unavailable.
unset ckaptitude
ckaptitude () {
    typeset pname=ckaptitude

    if ! which aptitude > /dev/null 2>&1 ; then

        ckapt || return "$?"

        elog -n "$pname" 'Installing aptitude..'

        if sudo apt-get update ; then
            sudo apt-get install -y aptitude 
        else
            elog -f -n "$pname" "apt-get update."
            return 1
        fi

        if ! which aptitude > /dev/null 2>&1 ; then
            elog -n "$pname" -f 'Failed installing aptitude. Aborted.'
            return 1
        fi
    fi

    elog -n "$pname" 'Check complete.'
}

# Function aptclean - clean up ubuntu packages and unwanted files.
# Rmk - this also installs localepurge, but it must be executed separately (in that
#   package you will choose only the locales you use and/or want to keep).
unset aptclean
aptclean () {
    typeset pname=aptclean
    typeset rmorphan

    elog -n "$pname" 'Started.'

    ckapt || return "$?"

    which deborphan > /dev/null 2>&1 || sudo aptitude install -y deborphan
    which localepurge > /dev/null 2>&1 || sudo aptitude install -y localepurge

    if which deborphan > /dev/null 2>&1 ; then
        echo '==> Orphaned packages:'
        sudo deborphan
        if userconfirm 'Remove?' ; then
            sudo deborphan | xargs sudo apt-get purge -y
        fi
    else
        elog -s -p "$pname" "No deborphan program available.."
    fi

    # Remove caches:
    userconfirm 'apt-get autoclean?' && sudo apt-get autoclean -y
    userconfirm 'apt-get clean?' && sudo apt-get clean -y

    elog -n "$pname" 'Completed.'
}

# Function aptinstall - Install packages listed in file.
# Syntax: [-u] [-y] filename
# Syntax description:
# -u means do upgrade
# -y means do assume yes (as per vanilla apt)
unset aptinstall
aptinstall () {
    typeset oldind="${OPTIND}"
    typeset assumeyes
    typeset doupdate=true
    typeset doupgrade=false

    OPTIND=1
    while getopts ':nuy' option ; do
        case "${option}" in
        n) doupdate=false;;
        u) doupgrade=true;;
        y) assumeyes='-y';;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"
  
    # Prep:

    if [[ $1 != dummy ]] && [ ! -r "${1}" ] ; then
        echo "A readable packagelist file must be passed as the first argument. Aborted." 1>&2
        return 1
    fi
    ckaptitude || return 1

    if ${doupdate} ; then
        sudo aptitude update || return 2
    fi

    if ${doupgrade} ; then
        sudo aptitude upgrade ${assumeyes} || return 11
    fi

    if [ -f "$1" ] ; then
        sudo aptitude install ${assumeyes} -Z $(sed -e 's/#.*$//' "$@" | grep .) || return 21
    elif [[ $1 != dummy ]] ; then
        sudo aptitude install ${assumeyes} -Z "$@" || return 22
    fi
}

# Function aptdeploy
# Purpose:
#   Install ubuntu packages.
# Remarks:
#   APTREMOVELIST global will cause aptitude purge to be called with that list.
unset aptdeploy
aptdeploy () {

    typeset pname=aptdeploy

    typeset ask=false
    typeset upgradeoption

    # Options:
    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':i' option ; do
        case "${option}" in
        i) ask=true;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    elog -n "$pname" 'Prep..'

    ckapt || return "$?"

    if _any_not_r "$@" ; then
        elog -f -n "$pname" "All argument files must be readable."
        return 1
    fi

    if [[ $- = *i* ]] && ask && ! userconfirm 'Proceed deploying APT assets?' ; then
        return
    fi

    if [[ $- = *i* ]] && userconfirm 'Upgrade all packages?' ; then
        upgradeoption='-u'
    fi

    elog -n "$pname" 'Started.'

    aptinstall -${upgradeoption}y "$@"

    fixaptmodes
    aptclean

    if [ -n "$APTREMOVELIST" ] ; then
        sudo aptitude purge $(echo $APTREMOVELIST)
    fi

    elog -n "$pname" 'Complete.'
}

# Function dpkgstat: View installation status of given package names.
# Deps: bash and debian based dpkg command.
# Output: dpkg -s output filtered by '^Package:|^Status:'
# Syntax: {pkg1} {pkg2} ... {pkgN}
unset dpkgstat
dpkgstat () {
    typeset usage='Syntax: ${0} {pkg1} {pkg2} ... {pkgN}'

    [ "${#}" -lt 1 ] && echo "${usage}" && return 1

    dpkg -s "$@" | \
    awk '
        /^Package:/ { pkg = $0; }
        /^Status:/ {
            stat = $0; printf("%-32s%s\n", pkg, stat);
        }'
}

# Function fixaptmodes - Fix workaround for /etc/apt/sources.list.d mode issue.
#   This will sudo chmod 644 to all files in /etc/apt/sources.list.d
# Rmk: Common scenario this glitch happens is a call to update after adding a ppa repo.
unset fixaptmodes
fixaptmodes () {
    if [ -d /etc/apt/sources.list.d ] ; then
        sudo chmod 644 /etc/apt/sources.list.d/*
    fi
}

# Function installppa - add ubuntu ppa repositories.
unset installppa
installppa () {

    typeset pname=installppa

    typeset somefail=false
    typeset ppalistfile="$1"
    typeset usage="${pname} {ppa file (one ppa path per line)}"

    ! _is_ubuntu && elog -f -n "$pname" "Not in ubuntu." && return 1

    [ ! -f "$ppalistfile" ] && elog -f -n "$pname" "${usage}" && return 1

    elog -n "$pname" 'Started.'

    [[ -n $ZSH_VERSION ]] && set -o shwordsplit

    for ppa in "$(cat "$ppalistfile")" ; do

        if ! (ls -1 /etc/apt/sources.list.d | \
            grep -q "$(echo "$ppa" | sed -e 's#/#-#g')")
        then
            elog -n "$pname" "Adding ppa: ${ppa}"

            if ! sudo apt-add-repository "ppa:${ppa}" ; then
                elog -f -n "$pname" "Failed installing '${ppa}' ppa."
                somefail=true
            fi
        else
            elog -s -n "$pname" "'${ppa}' ppa already present."
        fi

    done

    [[ -n $ZSH_VERSION ]] && set +o shwordsplit

    if $somefail ; then
        elog -f -n "$pname" 'Some ppa failed.'
        return 1
    else
        elog -n "$pname" 'Complete.'
    fi
}

