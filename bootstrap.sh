#!/usr/bin/env bash

# Ensure the underlying system is Fedora
if ! grep -iq "fedora" /etc/os-release; then
  echo -e "\nError: Aeterna Linux installation requires a Fedora-based system."
  exit 1
fi

# Check for sudo privs and cache credentials
sudo -v
if [ $? -ne 0 ]; then
  echo -e "\nThe Aeterna installation script requires sudo priviledges..."
  exit 1
fi

echo -e "\n- Checking for git..."
if rpm -q "git" &>/dev/null; then
  echo -e "\n- Git found!"
else
  echo -e "\n- Installing git..."
  dnf -y install git
  if [ $? -eq 0 ]; then
    echo -e "\n- Git installed successfully!"
  else
    echo -e "\n- Failed to install git."
    exit 1
  fi
fi

echo -e "\n- Cloning Aeterna Linux Github Repo For Installation..."

rm -rf ~/.local/share/aeterna/

git clone "https://github.com/d9j0m/aeterna.git" ~/.local/share/aeterna >/dev/null

echo -e "\n- Starting Aeterna Linux Installation..."

source ~/.local/share/aeterna/install.sh
