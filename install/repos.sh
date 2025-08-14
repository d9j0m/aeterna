#!/usr/bin/env bash

echo -e "\n- Configuring Fedora Repos..."

# Check if RPM Fusion Free is enabled
if ! dnf repolist | grep -q "rpmfusion-free"; then
  echo -e "\n-- Enabling RPM Fusion Free repository..."
  sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
  sudo dnf makecache
fi

# Check if RPM Fusion Nonfree is enabled
if ! dnf repolist | grep -q "rpmfusion-nonfree"; then
  echo -e "\n-- Enabling RPM Fusion Nonfree repository..."
  sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  sudo dnf makecache
fi

# Check if solopasha/hyprland COPR is enabled
if ! dnf repolist | grep -q "copr:copr.fedorainfracloud.org:solopasha:hyprland"; then
  echo -e "\n-- Enabling solopasha/hyprland COPR repository..."
  sudo dnf copr enable -y solopasha/hyprland
  if [ $? -ne 0 ]; then
    echo "Failed to enable solopasha/hyprland COPR repository."
    exit 1
  fi
  sudo dnf makecache
fi
