#!/usr/bin/env bash

echo -e "\nConfiguring Fedora Repos..."

if ! dnf repolist | grep -q "rpmfusion-free"; then
  echo "Enabling RPM Fusion Free repository..."
  sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
  sudo dnf groupupdate core
fi

if ! dnf repolist | grep -q "rpmfusion-nonfree"; then
  echo "Enabling RPM Fusion Nonfree repository..."
  sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  sudo dnf groupupdate core
fi
