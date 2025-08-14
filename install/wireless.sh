#!/bin/bash

# Exit on any error
set -e

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install required tools (pciutils, usbutils) if not installed
echo -e "\n-- Installing lspci and lsusb..."
if ! rpm -q pciutils >/dev/null 2>&1; then
  echo -e "\n-- Installing pciutils..."
  sudo dnf install -y pciutils
else
  echo -e "\n-- pciutils is already installed."
fi

if ! rpm -q usbutils >/dev/null 2>&1; then
  echo -e "\n-- Installing usbutils..."
  sudo dnf install -y usbutils
else
  echo -e "\n-- usbutils is already installed."
fi

# Identify wireless chipset
echo -e "\n-- Detecting wireless chipset..."
WIRELESS_INFO=""
if command_exists lspci; then
  WIRELESS_INFO=$(lspci -nn | grep -iE "network|wireless" || true)
fi

if command_exists lsusb && [ -z "$WIRELESS_INFO" ]; then
  WIRELESS_INFO=$(lsusb | grep -iE "wireless|wifi|network" || true)
fi

if [ -z "$WIRELESS_INFO" ]; then
  echo -e "\n-- Error: No wireless card detected. Please check hardware and try again."
  exit 1
fi
echo -e "\n-- Detected wireless device: $WIRELESS_INFO"

# Determine chipset and corresponding firmware package
FIRMWARE_PACKAGE=""
RPMFUSION_NEEDED=false

if echo "$WIRELESS_INFO" | grep -qi "intel"; then
  FIRMWARE_PACKAGE="iwlwifi-dvm-firmware iwlwifi-mvm-firmware"
elif echo "$WIRELESS_INFO" | grep -qi "broadcom"; then
  FIRMWARE_PACKAGE="broadcom-wl kmod-wl"
  RPMFUSION_NEEDED=true
elif echo "$WIRELESS_INFO" | grep -qi "realtek"; then
  FIRMWARE_PACKAGE="realtek-firmware"
elif echo "$WIRELESS_INFO" | grep -qi "qualcomm.*atheros"; then
  FIRMWARE_PACKAGE="atheros-firmware"
elif echo "$WIRELESS_INFO" | grep -qi "mediatek"; then
  FIRMWARE_PACKAGE="mt7xxx-firmware"
elif echo "$WIRELESS_INFO" | grep -qi "marvell.*libertas"; then
  FIRMWARE_PACKAGE="libertas-firmware"
elif echo "$WIRELESS_INFO" | grep -qi "nxp"; then
  FIRMWARE_PACKAGE="nxpwireless-firmware"
elif echo "$WIRELESS_INFO" | grep -qi "zd1211"; then
  FIRMWARE_PACKAGE="zd1211-firmware"
elif echo "$WIRELESS_INFO" | grep -qi "atmel"; then
  FIRMWARE_PACKAGE="atmel-firmware"
elif echo "$WIRELESS_INFO" | grep -qi "texas instruments"; then
  FIRMWARE_PACKAGE="tiwilink-firmware"
else
  echo -e "\n-- Error: Unsupported or unrecognized wireless chipset. Please check manually."
  echo -e "\n-- Try visiting https://wireless.kernel.org/en/users/Drivers for more info."
  exit 1
fi

# Install firmware if not installed
for pkg in $FIRMWARE_PACKAGE; do
  if ! rpm -q "$pkg" >/dev/null 2>&1; then
    echo "Installing firmware package: $pkg..."
    sudo dnf install -y "$pkg"
  else
    echo "Firmware package $pkg is already installed."
  fi
done

# Install iwd if not installed
if ! rpm -q iwd >/dev/null 2>&1; then
  echo -e "\n-- Installing iwd..."
  sudo dnf install -y iwd
else
  echo -e "\n-- iwd is already installed."
fi

# Disable wpa_supplicant to avoid conflicts with iwd
if sudo systemctl is-active --quiet wpa_supplicant; then
  echo -e "\n-- Disabling and stopping wpa_supplicant..."
  sudo systemctl disable --now wpa_supplicant
else
  echo -e "\n-- wpa_supplicant is already disabled or not running."
fi

# Create NetworkManager conf.d directory and unmanaged.conf file
echo -e "\n-- Configuring NetworkManager to ignore WiFi..."
mkdir -p /etc/NetworkManager/conf.d
if [ -f /etc/NetworkManager/conf.d/unmanaged.conf ]; then
  echo -e "\n-- Backing up existing NetworkManager unmanaged.conf..."
  cp /etc/NetworkManager/conf.d/unmanaged.conf /etc/NetworkManager/conf.d/unmanaged.conf.bak-$(date +%F-%H%M%S)
fi
cat <<EOF | tee /etc/NetworkManager/conf.d/unmanaged.conf
[keyfile]
unmanaged-devices=type:wifi
EOF

# Restart NetworkManager
echo -e "\n-- Restarting NetworkManager..."
sudo systemctl restart NetworkManager

# Create /etc/iwd/main.conf with IPv6 disabled
echo -e "\n-- Creating iwd configuration file..."
mkdir -p /etc/iwd
if [ -f /etc/iwd/main.conf ]; then
  echo -e "\n-- Backing up existing iwd configuration..."
  cp /etc/iwd/main.conf /etc/iwd/main.conf.bak-$(date +%F-%H%M%S)
fi
cat <<EOF | tee /etc/iwd/main.conf
[General]
EnableNetworkConfiguration=true
[Network]
EnableIPv6=false
EOF

# Enable and start iwd
if ! sudo systemctl is-active --quiet iwd; then
  echo -e "\n-- Enabling and starting iwd..."
  sudo systemctl enable --now iwd
else
  echo -e "\n-- iwd is already enabled and running."
fi

# Install Cargo if not installed
if ! rpm -q cargo >/dev/null 2>&1; then
  echo -e "\n-- Installing Cargo..."
  sudo dnf install -y cargo
else
  echo -e "\n-- Cargo is already installed."
fi

# Install impala system-wide
if [ ! -f /usr/local/bin/impala ] || ! /usr/local/bin/impala --version >/dev/null 2>&1; then
  echo -e "\n-- Installing Impala system-wide to /usr/local/bin..."
  cargo install impala --root /usr/local --force
else
  echo -e "\n-- Impala is already installed system-wide."
fi
