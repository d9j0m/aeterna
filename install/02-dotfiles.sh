#!/usr/bin/env bash

echo -e "\n--Copying .bashrc to ~/.bashrc"

cp -R ~/.local/share/aeterna/default/bashrc ~/.bashrc

echo -e "\n--Copying dotfiles to ~/.config/"

cp -R ~/.local/share/aeterna/config/* ~/.config/
