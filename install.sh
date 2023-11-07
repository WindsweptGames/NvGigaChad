#!/usr/bin/env bash

INSTALL_DIR=$HOME
TAR_DIR="nvim-linux64"
INSTALL_LINK="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
green=$(tput setaf 2)
yellow=$(tput setaf 3)
red=$(tput setaf 1)
normal=$(tput sgr0)

function printgln () {
  printf '%s%s%s\n' "${green}" "$1" "${normal}"
}

function printyln () {
  printf '%s%s%s\n' "${yellow}" "$1" "${normal}"
}

function printrln () {
  printf '%s%s%s\n' "${red}" "$1" "${normal}"
}


platform=$(uname -a | awk '{print $1;}' | head -n 1)
if [ "$platform" = "Darwin" ]; then
    INSTALL_LINK="https://github.com/neovim/neovim/releases/latest/download/nvim-macos.tar.gz"
    TAR_DIR="nvim-macos"
fi

if [ $# -eq 0 ]; then
    printyln "No installation directory provided, defaulting to $INSTALL_DIR"
  else
    INSTALL_DIR=$1
    printgln "Installing to $INSTALL_DIR"
fi

function yes_or_no () {
    while true; do
        read -rp "$* [y/N]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            *) echo "Aborted" ; return  1 ;;
        esac
    done
}

function install () {
  printgln 'Fetching Neovim...'
  mkdir -p "$INSTALL_DIR"
  curl -L -o "$INSTALL_DIR/nvim.tar.gz" "$INSTALL_LINK" 
  tar -zxf "$INSTALL_DIR/nvim.tar.gz" -C "$INSTALL_DIR"
  rm "$INSTALL_DIR/nvim.tar.gz"
  cmd="$INSTALL_DIR/$TAR_DIR/bin/nvim --version"
  check=$(eval "$cmd" | awk '{print $1;}' | head -n 1)
  printgln "Updating config at $HOME/.config/nvim"
  if [ "$check" = "NVIM" ]; then
    #install was successful so lets add the config
    git clone https://github.com/NvChad/NvChad "$HOME/.config/nvim" --depth 1
    git clone https://github.com/aWindsweptEmu/NvGigaChad-Config "$HOME/.config/nvim/lua/custom" --depth 1
  else
    printrln "Could not verify nvim installation, exiting..."
    exit 1
  fi
  printgln "Installation complete. Plugins will be installed when Neovim is started for the first time."
  printgln "Make sure to add Neovim to your path: export PATH=\$PATH:$INSTALL_DIR/$TAR_DIR/bin"
}

function uninstall () {
    printyln "Removing prior installation..."
    rm -rf "$HOME/.config/nvim"
    rm -rf "$HOME/.local/share/nvim"
    rm -rf "${INSTALL_DIR:?$HOME}/$TAR_DIR"
}

if [ -d "$INSTALL_DIR/$TAR_DIR" ]; then
  printyln "$INSTALL_DIR/$TAR_DIR already exists. Would you like to reinstall?" 
  if yes_or_no "${red}WARNING: This will replace your current installation and configuration! Continue?${normal}"; then
    uninstall
    install
  fi 
else
  install
fi
