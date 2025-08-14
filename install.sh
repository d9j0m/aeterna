#!/usr/bin/env bash

aeterna_logo='
              _                          _      _
    /\       | |                        | |    (_)
   /  \   ___| |_ ___ _ __ _ __   __ _  | |     _ _ __  _   ___  __
  / /\ \ / _ \ __/ _ \  __|  _ \ / _  | | |    | |  _ \| | | \ \/ /
 / ____ \  __/ ||  __/ |  | | | | (_| | | |____| | | | | |_| |>  <
/_/    \_\___|\__\___|_|  |_| |_|\__,_| |______|_|_| |_|\__,_/_/\_\              '

clear

echo -e "\n$aeterna_logo\n"

echo -e "\n- Beginning Aeterna Installation..."

echo -e "\n- Checking for Updates..."

sudo dnf update

source ~/.local/share/aeterna/install/01-repos.sh
source ~/.local/share/aeterna/install/02-dotfiles.sh
source ~/.local/share/aeterna/install/03-wireless.sh
