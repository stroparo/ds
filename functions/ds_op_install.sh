# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Application installation routines

autostartdropbox () {
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
}

installatom () {

    if which atom >/dev/null 2>&1 ; then return ; fi

    if _is_cygwin ; then

        wget 'https://atom.io/download/windows'
        mv windows atomsetup.exe
        chmod u+x atomsetup.exe && ./atomsetup.exe && rm -f ./atomsetup.exe

    elif _is_debian || _is_ubuntu ; then

        wget 'https://atom.io/download/deb'
        sudo dpkg -i deb && rm -f deb

    elif _is_redhat ; then

        wget 'https://atom.io/download/rpm'
        sudo rpm -ivh rpm && rm -f rpm
    fi
}

installdropbox () {
    _is_linux || return
    [ -e ~/.dropbox-dist/dropboxd ] && return

    echo '==> Installing dropbox...' 1>&2

    cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | \
        tar xzf -

    env DBUS_SESSION_BUS_ADDRESS='' "${HOME}"/.dropbox-dist/dropboxd > /dev/null 2>&1 &
}

installexa () {
    _is_debian || _is_ubuntu || return

    which exa >/dev/null 2>&1 && return

    echo ${BASH_VERSION:+-e} '\n\n==> Installing exa...' 1>&2

    [ ! -d ~/bin ] && ! mkdir ~/bin && return 1

    # Rust language
    curl https://sh.rustup.rs -sSf | sh
    pathmunge -x ~/.cargo/bin

    # Deps
    sudo apt update || return 1
    sudo apt install libgit2-dev cmake git libhttp-parser2.1 || return 1

    # Compile and install exa
    git clone https://github.com/ogham/exa.git /tmp/exa
    (cd /tmp/exa && make install)
    sudo cp /tmp/exa/target/release/exa /usr/local/bin/exa \
    && rm -rf /tmp/exa
}

installohmyzsh () {
    which zsh >/dev/null || return 1
    [ -d "${HOME}/.oh-my-zsh" ] && return

    echo ${BASH_VERSION:+-e} '\n\n==> Installing ohmyzsh...' 1>&2

    sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

    # Plugin zsh-syntax-highlighting:
    git clone 'https://github.com/zsh-users/zsh-syntax-highlighting.git' ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    if ! grep -q 'plugins=.*zsh-syntax-highlighting' < ~/.zshrc ; then
        sed -i -e 's/\(plugins=(.*\))/\1 zsh-syntax-highlighting)/' ~/.zshrc
    fi
}

installpowerfonts () {
    _is_linux || return
    [ -e "$HOME/.local/share/fonts/Inconsolata for Powerline.otf" ] && return

    echo ${BASH_VERSION:+-e} '\n\n==> Installing powerline fonts...' 1>&2

    wget https://github.com/powerline/fonts/archive/master.zip -O ~/powerline.zip
    (cd ~ ; unzip powerline.zip)
    ~/fonts-master/install.sh && rm -rf ~/fonts-master ~/powerline.zip
}

# ##############################################################################

