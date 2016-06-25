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
# Desktop-most software

unset installdropbox
installdropbox () {

    typeset pname=installdropbox

    echo '==> Installing dropbox..' 1>&2

    if _is_linux ; then
        if [ ! -e ~/.dropbox-dist/dropboxd ] ; then
            cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -

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
            elog -n "$pname" 'Launching dropbox..'
            env DBUS_SESSION_BUS_ADDRESS='' "${HOME}"/.dropbox-dist/dropboxd > /dev/null 2>&1 &

            elog -n "$pname" 'Completed.'
        else
            elog -s -n "$pname" 'It was installed already.'
        fi
    else
        elog -s -n "$pname" 'Not in Linux, so nothing done.'
    fi
}

# Function installinputfont - Installs local input font package
# Syntax: {input-font-package-filename}
unset installinputfont
installinputfont () {

    typeset pname=installinputfont
    typeset find_command="find \"$HOME/Input_Fonts\" \( -name '*.[o,t]tf' -or -name '*.pcf.gz' \) -type f -print0"
    typeset font_dir="$HOME/.local/share/fonts"
    typeset inputfontpackage="$1"

    echo '==> Installing input font..' 1>&2

    if ! _is_linux ; then
        elog -s -n "$pname" 'Only Linux supported.'
        return
    elif [ ! -e "$inputfontpackage" ] ; then
        elog -f -n "$pname" 'Invalid input font package location (first argument).'
        return 1
    elif [ -e "$font_dir/InputMono-Regular.ttf" ] ; then
        elog -s -n "$pname" 'It was installed already.'
        return
    fi

    unzip -d "$HOME" "$inputfontpackage" 'Input_Fonts/*'
    test -d "$font_dir" || mkdir -p "$font_dir"
    eval $find_command | xargs -0 -I % cp "%" "$font_dir/"
    rm -rf "$HOME/Input_Fonts"

    # Reset font cache on Linux
    if command -v fc-cache @>/dev/null ; then
        elog -n "$pname" "Resetting font cache, this may take a moment..."
        fc-cache -f "$font_dir"
    fi

    elog -n "$pname" "Finished installing fonts to '$font_dir'."
}

# Function installpowerfonts - Install powerline fonts.
unset installpowerfonts
installpowerfonts () {

    echo '==> Installing powerline fonts..' 1>&2

    if _is_linux ; then
        if [ ! -e "$HOME/.local/share/fonts/Inconsolata for Powerline.otf" ] ; then
            wget https://github.com/powerline/fonts/archive/master.zip -O ~/powerline.zip
            (cd ~ ; unzip powerline.zip)
            ~/fonts-master/install.sh && rm -rf ~/fonts-master ~/powerline.zip
        else
            echo 'It was installed already.' 1>&2
        fi
    else
        echo 'Not in Linux, so nothing done.' 1>&2
    fi
}

# Function installyoutubedl
unset installyoutubedl
installyoutubedl () {

    typeset youtubedlpath='/usr/local/bin/youtube-dl'

    echo '==> Installing youtube-dl..' 1>&2

    if _is_linux ; then
        if [ ! -e "${youtubedlpath}" ] ; then
            sudo wget 'https://yt-dl.org/latest/youtube-dl' -O "${youtubedlpath}"
            sudo chmod a+rx "${youtubedlpath}"
        else
            echo 'It was installed already.' 1>&2
        fi
    else
        echo 'Not in Linux, so nothing done.' 1>&2
    fi
}

# ##############################################################################

