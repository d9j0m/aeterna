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

echo -e "\n-- Checking for git..."
if rpm -q "git" &>/dev/null; then
    echo -e "\n-- Git found!"
else
    echo -e "\n-- Installing git..."
    sudo dnf -y install git
    if [ $? -eq 0 ]; then
        echo -e "\n-- Git installed successfully!"
    else
        echo -e "\n-- Failed to install git."
        exit 1
    fi
fi

#echo -e "\n-- Cloning Aeterna Linux Github Repo For Installation..."

#rm -rf ~/.local/share/aeterna/

#git clone "https://github.com/d9j0m/aeterna.git" ~/.local/share/aeterna > /dev/null

#echo -e "\nStarting Aeterna Linux Installation..."

#source ~/.local/share/aeterna/install.sh
