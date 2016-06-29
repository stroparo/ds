# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Admin - install & setup functions

# Function installohmyzsh - Install Oh My ZSH.
unset installohmyzsh
installohmyzsh () {

    echo '==> Installing ohmyzsh..' 1>&2

    if which zsh >/dev/null && [ ! -d "${HOME}/.oh-my-zsh" ] ; then
        sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    else
        echo 'FATAL: Must have zsh installed.'
        return 1
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

    if ! _is_linux ; then

        echo 'SKIP: Not in Linux, so nothing done.' 1>&2
        return

    elif [ -e "${truecryptpath}" ] ; then

        echo "SKIP: Truecrypt already installed at '${truecryptpath}'" 1>&2
        return

    elif [ ! -e "${pkg}" ] ; then

        echo "FATAL: Missing required package '${pkg}'." 1>&2
        return 1

    elif tar -xzf "${pkg}" -C "${pkgdir}" ; then

        echo "Installing '${pkginstaller}'.." 1>&2

        if "${pkginstaller}" ; then
            rm -f "${pkginstaller}"
        fi

        echo 'Truecrypt installation complete.' 1>&2
    else
        echo 'FATAL: Truecrypt installation failed.' 1>&2
        return 1
    fi
}

# ##############################################################################
# Desktop-most software

unset installdropbox
installdropbox () {

    echo '==> Installing dropbox..' 1>&2

    if ! _is_linux ; then

        echo 'SKIP: Not in Linux, so nothing done.' 1>&2
        return

    elif [ -e ~/.dropbox-dist/dropboxd ] ; then

        echo 'SKIP: It was installed already.' 1>&2
        return

    fi

    cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | \
        tar xzf -

    # Desktop tray workaround (export empty DBUS_SESSION_BUS_ADDRESS for process):
    # This first approach doesnt work as Dropbox often updates itself:
    # sed -i -e 's/^exec.*dropbox/export DBUS_SESSION_BUS_ADDRESS=""; &/' ~/.dropbox-dist/dropboxd
    cat > ~/.config/autostart/dropbox.desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=dropbox
Comment=dropbox
Exec=env DBUS_SESSION_BUS_ADDRESS='' ${HOME}/.dropbox-dist/dropboxd
OnlyShowIn=XFCE;
StartupNotify=false
Terminal=false
Hidden=false
EOF
    echo 'Launching dropbox..' 1>&2
    env DBUS_SESSION_BUS_ADDRESS='' "${HOME}"/.dropbox-dist/dropboxd > /dev/null 2>&1 &

    echo 'Dropbox installation complete.' 1>&2
}

# Function installinputfont - Installs local input font package
# Syntax: {input-font-package-filename}
unset installinputfont
installinputfont () {

    typeset find_command="find \"$HOME/Input_Fonts\" \( -name '*.[o,t]tf' -or -name '*.pcf.gz' \) -type f -print0"
    typeset font_dir="$HOME/.local/share/fonts"
    typeset inputfontpackage="$1"

    echo '==> Installing input font..' 1>&2

    if ! _is_linux ; then

        echo 'SKIP: Not in Linux, so nothing done.' 1>&2
        return

    elif [ -e "$font_dir/InputMono-Regular.ttf" ] ; then

        echo 'SKIP: It was installed already.' 1>&2
        return

    elif [ ! -e "$inputfontpackage" ] ; then

        echo 'FATAL: Invalid input font package location (first argument).' 1>&2
        return 1

    fi

    unzip -d "$HOME" "$inputfontpackage" 'Input_Fonts/*'

    if [ ! -d "$font_dir" ] ; then
        mkdir -p "$font_dir"
    fi

    eval $find_command | xargs -0 -I % cp "%" "$font_dir/"
    rm -rf "$HOME/Input_Fonts"

    if [ -e "$font_dir/InputMono-Regular.ttf" ] ; then

        # Reset font cache on Linux
        if command -v fc-cache @>/dev/null ; then
            echo "Resetting font cache, this may take a moment..." 1>&2
            fc-cache -f "$font_dir"
        fi

        echo "Input fonts installed into '$font_dir'." 1>&2
    else
        echo "FATAL: Failure installing input fonts to '$font_dir'." 1>&2
        return 1
    fi
}

# Function installpowerfonts - Install powerline fonts.
unset installpowerfonts
installpowerfonts () {

    echo '==> Installing powerline fonts..' 1>&2

    if ! _is_linux ; then

        echo 'SKIP: Not in Linux, so nothing done.' 1>&2
        return

    elif [ -e "$HOME/.local/share/fonts/Inconsolata for Powerline.otf" ] ; then

        echo 'SKIP: It was installed already.' 1>&2
        return
    fi

    wget https://github.com/powerline/fonts/archive/master.zip -O ~/powerline.zip
    (cd ~ ; unzip powerline.zip)

    if ~/fonts-master/install.sh ; then

        rm -rf ~/fonts-master ~/powerline.zip
        echo 'Powerfonts sucessfully installed.' 1>&2
    else
        echo 'FATAL: Failure during powerfonts installation.' 1>&2
        return 1
    fi
}

# Function installyoutubedl
unset installyoutubedl
installyoutubedl () {

    typeset youtubedlpath='/usr/local/bin/youtube-dl'

    echo '==> Installing youtube-dl..' 1>&2

    if ! _is_linux ; then

        echo 'SKIP: Not in Linux, so nothing done.' 1>&2
        return

    elif [ -e "${youtubedlpath}" ] ; then

        echo 'SKIP: It was installed already.' 1>&2
        return
    fi

    sudo wget -q -O "${youtubedlpath}" 'https://yt-dl.org/latest/youtube-dl'
    sudo chmod a+rx "${youtubedlpath}"

    if ls -l "${youtubedlpath}" ; then
        echo 'Installation complete.' 1>&2
    else
        echo 'FATAL: Installation failed.' 1>&2
    fi
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

