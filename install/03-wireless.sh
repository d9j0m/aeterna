#!/bin/bash

# Exit on any error
set -e

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}
# Install required tools
echo "Installing lspci and lsusb..."
sudo dnf install pciutils usbutils -y

# Identify wireless chipset
echo "Detecting wireless chipset..."
WIRELESS_INFO=""
if command_exists lspci; then
  WIRELESS_INFO=$(lspci -nn | grep -iE "network|wireless" || true)
fi
if command_exists lsusb && [ -z "$WIRELESS_INFO" ]; then
  WIRELESS_INFO=$(lsusb | grep -iE "wireless|wifi|network" || true)
fi

if [ -z "$WIRELESS_INFO" ]; then
  echo "Error: No wireless card detected. Please check hardware and try again."
  exit 1
fi

echo "Detected wireless device: $WIRELESS_INFO"

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
  echo "Error: Unsupported or unrecognized wireless chipset. Please check manually."
  echo "Try visiting https://wireless.kernel.org/en/users/Drivers for more info."
  exit 1
fi

# Install NetworkManager-wifi and firmware
echo "Installing NetworkManager-wifi and firmware package(s): $FIRMWARE_PACKAGE..."
sudo dnf install NetworkManager-wifi $FIRMWARE_PACKAGE -y

# Install iwd
echo "Installing iwd..."
sudo dnf install iwd -y

# Create NetworkManager conf.d directory and unmanaged.conf file
echo "Configuring NetworkManager to ignore WiFi..."
sudo mkdir -p /etc/NetworkManager/conf.d
cat <<EOF | sudo tee /etc/NetworkManager/conf.d/unmanaged.conf
[keyfile]
unmanaged-devices=type:wifi
EOF

# Restart NetworkManager
echo "Restarting NetworkManager..."
sudo systemctl restart NetworkManager

# Create /etc/iwd/main.conf with IPv6 disabled
echo "Creating iwd configuration file..."
sudo mkdir -p /etc/iwd
cat <<EOF | sudo tee /etc/iwd/main.conf
[General]
EnableNetworkConfiguration=true
[Network]
EnableIPv6=false
EOF

# Enable and start iwd
echo "Enabling and starting iwd..."
sudo systemctl enable --now iwd

# Install Cargo
echo "Installing Cargo..."
sudo dnf install cargo -y

# Install Impala system-wide
echo "Installing Impala system-wide to /usr/local/bin..."
sudo cargo install impala --root /usr/local --force
