#!/usr/bin/env bash

INSTALL_DIR=$HOME
TAR_DIR="nvim-linux64"

if [ $# -eq 0 ]; then
    printf 'No installation directory provided, installing to %s\n' "$INSTALL_DIR"
  else
    INSTALL_DIR=$1
    printf 'Installing to %s\n' "$INSTALL_DIR"
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
  printf "Fetching Neovim..."
  mkdir -p "$INSTALL_DIR"
  curl -L -o "$INSTALL_DIR/nvim.tar.gz" https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
  tar -zxf "$INSTALL_DIR/nvim.tar.gz" -C "$INSTALL_DIR"
  rm "$INSTALL_DIR/nvim.tar.gz"
  cmd="$INSTALL_DIR/$TAR_DIR/bin/nvim --version"
  check=$(eval "$cmd" | awk '{print $1;}' | head -n 1)
  printf "Updating config at %s/.config/nvim\n" "$HOME"
  if [ "$check" = "NVIM" ]; then
    #install was successful so lets add the config
    rm -rf "$HOME/.config/nvim"
    git clone https://github.com/NvChad/NvChad "$HOME/.config/nvim" --depth 1
    git clone https://github.com/aWindsweptEmu/nvchad-custom "$HOME/.config/nvim/lua/custom" --depth 1
  else
    printf "Could not verify nvim, exiting..."
    exit 1
  fi
  printf "Make sure to add Neovim to your path: export PATH=\$PATH:%s/bin\n" "$INSTALL_DIR/$TAR_DIR"
}

if [ -d "$INSTALL_DIR/$TAR_DIR" ]; then
  if yes_or_no "$INSTALL_DIR/$TAR_DIR already exists. Would you like to reinstall? This will remove your current installation and configuration!\n"; then
    rm -rf "${INSTALL_DIR:?$HOME}/$TAR_DIR"
    install
  fi 
else
  install
fi
