# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Admin & ops functions

# Service script wrapper functions:
cthttpd () { sudo "/etc/init.d/apache${2:-2}"  "${1:-restart}" ; }
ctlamp ()  { sudo "${LAMPHOME}/ctlscript.sh"   "${1:-restart}" ; }
ctpg ()    { sudo "/etc/init.d/postgresql${2}" "${1:-restart}" ; }

# Function drop_caches_3: drop I/O caches etcetera TODO review this text.
unset drop_caches_3
drop_caches_3 () {
    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
}

# Function makeat - run configure, make & makeinstall for custom dir/prefix.
# Default directory will be ~/opt/root
unset makeat
makeat () {

    mkdir "${1:-${HOME}/opt/root}" 2> /dev/null || return
    ./configure --prefix="${1:-${HOME}/opt/root}" && \
    make && \
    make install
  
    echo "Exit status: ""$?"
}

# ##############################################################################
# Debian

# Function ckaptitude - checks and installs aptitude if unavailable.
unset ckaptitude
ckaptitude () {
    typeset pname=ckaptitude

    if ! which aptitude > /dev/null 2>&1 ; then
        elog -n "$pname" 'Installing aptitude..'

        sudo apt-get update \
        && sudo apt-get install -y aptitude 

        if ! which aptitude > /dev/null 2>&1 ; then
            elog -n "$pname" -f 'Failed installing aptitude. Aborted.'
            return 1
        fi
        elog -n "$pname" 'Done installing aptitude.'
    fi
}

# Function aptclean - clean up ubuntu packages and unwanted files.
# Rmk - this also installs localepurge, but it must be executed separately (in that
#   package you will choose only the locales you use and/or want to keep).
unset aptclean
aptclean () {
    typeset pname=aptclean
    typeset rmorphan

    elog -n "$pname" 'Started.'

    ckaptitude || return 1
    sudo aptitude update || return 2

    which deborphan > /dev/null 2>&1 || sudo aptitude install -y deborphan
    which localepurge > /dev/null 2>&1 || sudo aptitude install -y localepurge

    # Remove bulky stock packages:
    sudo aptitude purge -y oxygen-icon-theme

    # Remove orphaned packages:
    if which deborphan > /dev/null 2>&1 ; then
        elog -n "$pname" '...'
        elog -n "$pname" 'Orphaned packages:'
        sudo deborphan
        elog -n "$pname" 'Remove? (y|n) '
        read rmorphan
        if [[ ${rmorphan} = y* ]] ; then
            sudo deborphan | xargs sudo apt-get purge -y
        fi
    fi

    # Remove caches:
    sudo apt-get autoclean -y
    sudo apt-get clean -y

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
    typeset assumeyes doupgrade pkgslist

    [[ $SHELL = *zsh* ]] && set -o shwordsplit

    OPTIND=1
    while getopts ':uy' option ; do
        case "${option}" in
        u) doupgrade=true;;
        y) assumeyes='-y';;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"
  
    if [ ! -r "${1}" ] ; then
        echo "A readable packagelist file must be passed as the first argument. Aborted." 1>&2
        return 1
    fi
    pkgslist=$(sed -e 's/#.*$//' "${1}" | grep .)

    ckaptitude || return 1
    sudo aptitude update || return 2
  
    if ${doupgrade:-false} ; then
        sudo aptitude upgrade ${assumeyes} || return 11
    fi
    sudo aptitude install ${assumeyes} -Z ${pkgslist} || return 21

    [[ $SHELL = *zsh* ]] && set +o shwordsplit
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

# ##############################################################################
# Installations

# Function installohmyzsh - Install Oh My ZSH.
unset installohmyzsh
installohmyzsh () {
    echo '==> Installing ohmyzsh..' 1>&2

    if which zsh >/dev/null && [ ! -d "${HOME}/.oh-my-zsh" ] ; then
        sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    fi
}

# Function installtruecrypt - Install truecrypt encryption software.
# Syntax: {package-filename}
unset installtruecrypt
installtruecrypt () {
    typeset pkg="${1}"
    typeset pkgdir="$(dirname "${pkg}")"
    typeset pkginstaller="${pkgdir}/truecrypt-7.1a-setup-x64"
    typeset truecryptpath="/usr/bin/truecrypt"
    echo '==> Installing truecrypt..' 1>&2

    if _is_linux ; then
        if [ -e "${truecryptpath}" ] ; then
            echo "Truecrypt already installed at '${truecryptpath}'" 1>&2
            return 0
        elif [ ! -e "${pkg}" ] ; then
            echo "Missing required package '${pkg}'." 1>&2
            return 1
        else
            tar -xzf "${pkg}" -C "${pkgdir}"
            echo "Installing '${pkginstaller}'.." 1>&2
            "${pkginstaller}" && rm -f "${pkginstaller}"
        fi
    fi
}

# ##############################################################################
# Networking facilities

# Function pushl - push files to specific target environments. LFTP variant.
#
# Remarks:
# 1) The environment list must be in the tgt{env} variable.
#       Each entry in the env list must be formatted like this:
#       {environment-name}:{user}:{pass}:{host}:{destination-path}
# 2) tgtglob{env} variable might contain additional space-separated globs.
#       But globs are passed via the -f option (-f "glob1 glob2 ...")
#       so only those are going to be considered whereas tgtglob will
#       only serve as the default/fallback.
# 3) -r option
#       Reset files, i.e. deletes them from destination before copying.
# 4) -p option
#       Causes pushl to only purge all files in the destination
#       Usage of -r is redundant here.
#
# Syntax: [-e {env-regex}] [-f {local-globs}] [-p] [-r] {srcdir} {site} [site2 [site3 ...]]
unset pushl
pushl () {
    typeset oldind="${OPTIND}"
    typeset env_regex purge_only reset_files srcdir xglobs xglobsarg
    which lftp >/dev/null 2>&1 || return 10

    OPTIND=1
    while getopts ':e:f:pr' opt ; do
        case ${opt} in
        e) env_regex="${OPTARG}";;
        f) xglobsarg="${OPTARG}" ; xglobs="${OPTARG}" ;;
        p) purge_only=true;;
        r) reset_files=true;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    srcdir="$(cd ${1}; echo "$PWD")"
    shift

    for env in "$@" ; do
        if [ -z "${xglobsarg}" ] ; then
            xglobs="$(eval echo "\"\${tgtglob${env}}\"")"
        fi

        echo "==> Env: '${env}'; Files: '${xglobs}' <=="

        while IFS=':' read environ u pw h dest ; do
            [[ -z "${u}" ]] && continue

            # Filter host name:
            if ! grep -q "${env_regex}" ; then
                continue
            fi <<EOF
${environ}
EOF
            echo "${environ} => ${purge_only:+rm in }path: '${u}@${h}:${dest#/}'."

            if ${reset_files:-false} || ${purge_only:-false} ; then
                lftp -e 'set sftp:auto-confirm yes ; mrm -f '"${xglobs}"' ; exit' -u "${u},${pw}" "sftp://${h}/${dest#/}"
            fi
            ${purge_only:-false} && continue

            # Put files:
            cd "${srcdir:-err}" \
            && lftp -e 'set sftp:auto-confirm yes ; mput '"${xglobs}"' ; exit' -u "${u},${pw}" "sftp://${h}/${dest#/}"

            if [ "$?" != 0 ] ; then echo "${environ} => error"\! ; return 1 ; fi
        done <<EOF
$(eval echo "\"\${tgt${env}}\"")
EOF
    done
    echo 'Pushing process complete.'
}

# ##############################################################################
# Java

# Function loadjava - load environment variables based on JAVA_HOME path.
#  Option -v displays JAVA_HOME.
# Syntax: [-v] [JAVA_HOME override]
unset loadjava
loadjava () {
    typeset oldind="${OPTIND}"
    typeset doverbose
    typeset isjdk

    OPTIND=1
    while getopts ':v' opt ; do
        case "${opt}" in
        v) doverbose=true ;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"
  
    if [ -x "${1}/bin/java" ] ; then
        export JAVA_HOME="${1}"
    elif [ ! -x "${JAVA_HOME}/bin/java" ] ; then
        return 1
    fi
  
    if [ -n "${doverbose:-}" ] ; then
        echo "JAVA_HOME=${JAVA_HOME}" 1>&2
    fi
  
    # For JDK also add its root bin and lib subdirectories:
    if [[ ${JAVA_HOME} = *jdk* ]] ; then
        isjdk=true
        PATH="${JAVA_HOME}/lib:${PATH}"
        PATH="${JAVA_HOME}/bin:${PATH}"
    fi
  
    # For JDK the basic JRE binaries are inside the jre subdirectory:
    CLASSPATH="${JAVA_HOME:+${JAVA_HOME}/${isjdk:+jre/}lib/rt.jar}:${CLASSPATH}"
    LD_LIBRARY_PATH="${JAVA_HOME}/${isjdk:+jre/}lib:${LD_LIBRARY_PATH}"
    LD_LIBRARY_PATH="${JAVA_HOME}/${isjdk:+jre/}lib/amd64/server:${LD_LIBRARY_PATH}"
    LD_LIBRARY_PATH="${JAVA_HOME}/${isjdk:+jre/}bin:${LD_LIBRARY_PATH}"
    LD_LIBRARY_PATH="${JAVA_HOME}/${isjdk:+jre/}bin/client:${LD_LIBRARY_PATH}"
    PATH="${JAVA_HOME}/${isjdk:+jre/}lib:${PATH}"
    PATH="${JAVA_HOME}/${isjdk:+jre/}lib/amd64/server:${PATH}"
    PATH="${JAVA_HOME}/${isjdk:+bin:${JAVA_HOME}/jre/}bin:${PATH}"
    PATH="${JAVA_HOME}/${isjdk:+jre/}bin/client:${PATH}"
    export CLASSPATH="${CLASSPATH%:}"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH%:}"
    export LIBPATH="${LIBPATH}:${LD_LIBRARY_PATH}"
    export PATH="${PATH%:}"
  
    unset isjdk
}

# ##############################################################################
# Python

# Function addpystartup - Add default .pystartup to home folder.
# No effect if file already exists.
unset addpystartup
addpystartup () {

    if [ -e ~/.pystartup ] ; then
        echo 'Nothing done because there is a ~/.pystartup file already.' 1>&2
        return
    fi

    cat > ~/.pystartup <<EOF
# Add auto-completion and a stored history file of commands to your Python
# interactive interpreter. Requires Python 2.0+, readline. Autocomplete is
# bound to the Esc key by default (you can change it - see readline docs).
#
# Store the file in ~/.pystartup, and set an environment variable to point
# to it: "export PYTHONSTARTUP=/home/user/.pystartup" in bash.
#
# Note that PYTHONSTARTUP does *not* expand "~", so you have to put in the
# full path to your home directory.
import atexit
import os
import readline
import rlcompleter

readline.parse_and_bind('tab: complete')

historyPath = os.path.expanduser("~/.pyhistory")

def save_history(historyPath=historyPath):
    import readline
    readline.write_history_file(historyPath)

if os.path.exists(historyPath):
    readline.read_history_file(historyPath)

atexit.register(save_history)
del os, atexit, readline, rlcompleter, save_history, historyPath
EOF

}

# ##############################################################################
# Remote - Shell
# EE - Enter-Environment routines for ssh and scp operations

# Globals:
# EEPATH (export):
#  Directories containing (recursively) ee.txt files to load entries from,
#  each entry syntax being:
#
# [entry]
# attribute=value
#
# Mandatory attributes:
# ee_desc='description'
# ee_user=user
# ee_host=hostname
#
# Optional attributes:
# ee_cmd='some command'
# ee_id='some .pem or other file to be handled to ssh -i option'

alias eep='scp ${ee_id:+ -i "${ee_id}"}'

# Enter environment list available in EEPATH ee.txt files:
eel () {
    while IFS=: read eepath ; do
        # Search for the entry in EEPATH ee.txt files and setup variables if found:
        while read eefile ; do
            echo "==> '${eefile}' <==" 1>&2

            awk '/^ *\[.*\] *$/ {
                if (waitingdesc) {
                    print name;
                }
                gsub(/[][]/, "")
                name = $0;
                waitingdesc = 1;
            }

            /^ *ee_desc *=/ {
                gsub(/'"'"'| *ee_desc= */, "");
                desc = $0;
                print name ": " desc;
                waitingdesc = 0;
            }' \
            "${eefile}"
        done <<EOF
$(find "${eepath}" -type f -name 'ee.txt')
EOF
    done <<EOF
${EEPATH}
EOF
}

# Enter environment execute ie connect to the environment. System command is ssh.
eex () {
    if test -n "${ee_cmd}" && test -z "${1}" ; then
        echo 'WARN: There is ee_cmd set but this eex call has no arguments.' 1>&2
    fi

    if [ -n "${ee_id}" ] ; then
        ssh -i "${ee_id}" -l "${ee_user}" "${ee_host}" "$@"
    else
        ssh -l "${ee_user}" "${ee_host}" "$@"
    fi
}

# Function ees - Enter-Environment select environment (sets up env. variables).
ee () {
    typeset oldind="${OPTIND}"
    typeset ee_name_search eefile eepath selectonly
    ee_name=""; ee_desc=""; ee_user=""; ee_host=""; ee_domain=""; ee_id=""; ee_cmd=""

    OPTIND=1
    while getopts ':s' opt ; do
        case "${opt}" in
        s) selectonly=true ;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    ee_name_search="$1"
    shift

    if [ -z "${ee_name_search}" ] ; then
        echo 'FAIL: Must pass a nonempty environment name/id.' 1>&2
        return 1
    fi

    # Search for the entry in EEPATH ee.txt files and setup variables if found:
    while IFS=: read eepath ; do
        while read eefile ; do
            eval "$(awk -vee_name_search="${ee_name_search}" '

            # Find the entry:
            /^ *\['"${ee_name_search}"'\] *$/ { found = 1; print "ee_name=" ee_name_search; }

            # Print entry content:
            found && $0 ~ /^ *[^[]/ { inbody = 1; print; }

            # Stop on next entry after printing:
            inbody && $0 ~ /^ *\[/ { exit 0; }
            ' "${eefile}")"

            test -n "${ee_name}" && break
        done <<EOF
$(find "${eepath}" -type f -name 'ee.txt')
EOF
        test -n "${ee_name}" && break
    done <<EOF
${EEPATH}
EOF
    # Execute if the environment was found:
    if test -n "${ee_name}" ; then
        if test -n "${selectonly}" ; then
            echo "Selected '${ee_desc:-${env_name}}': ${ee_user}@${ee_host}"
        else
            if [ "${ee_cmd}" != "" ] ; then
                eex ${ee_cmd}
            else
                eex "$@"
            fi
        fi
        return 0
    fi

    echo "No environment found." 1>&2
    return 1
}

# Function screenb - run a bash shell in a screen session.
# Syntax: [sessionname]
unset screenb
screenb () {
    screen -S "${1:-screenbash}" bash
}

# Function screenk - run a ksh shell in a screen session.
# Syntax: [sessionname]
unset screenk
screenk () {
    env ENV="${HOME}/.kshrc" screen -S "${1:-screenksh}" ksh
}

# ##############################################################################

