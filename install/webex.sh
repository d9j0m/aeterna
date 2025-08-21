#!/bin/bash

# Exit on any error
set -e

# Define variables
WEBEX_URL="https://binaries.webex.com/Webex-Desktop-Linux-RPM/latest/webex.rpm"
WEBEX_RPM="Webex.rpm"
WEBEX_PUBLIC_KEY_URL="https://binaries.webex.com/Webex-Desktop-Linux-RPM/latest/webex_public.key"
WEBEX_PUBLIC_KEY="webex_public.key"
WEBEX_HASH_URL="https://binaries.webex.com/Webex-Desktop-Linux-RPM/latest/webex.rpm.sha512sum"
WEBEX_HASH="webex.rpm.sha512sum"

# Step 1: Download the latest Webex RPM
echo "Downloading the latest Webex RPM..."
curl -L -o "$WEBEX_RPM" "$WEBEX_URL"

# Step 2: Download the Webex public key
echo "Downloading the Webex public key..."
curl -L -o "$WEBEX_PUBLIC_KEY" "$WEBEX_PUBLIC_KEY_URL"

# Step 3: Download the SHA512 checksum file
echo "Downloading the SHA512 checksum..."
curl -L -o "$WEBEX_HASH" "$WEBEX_HASH_URL"

# Step 4: Verify the hash
echo "Verifying the RPM hash..."
sha512sum -c "$WEBEX_HASH"

# Step 5: Import the public key for RPM verification
echo "Importing Webex public key..."
sudo rpm --import "$WEBEX_PUBLIC_KEY"

# Step 6: Install the Webex RPM using dnf
echo "Installing Webex RPM..."
sudo dnf install -y "$WEBEX_RPM"

# Step 7: Clean up downloaded files
echo "Cleaning up..."
rm -f "$WEBEX_RPM" "$WEBEX_PUBLIC_KEY" "$WEBEX_HASH"

echo "Webex installation completed successfully!"
