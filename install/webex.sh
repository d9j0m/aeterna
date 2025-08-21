#!/bin/bash

# Exit on any error, but allow specific error handling
set -e

# Define variables
WEBEX_URL="https://binaries.webex.com/WebexDesktop-CentOS-Official-Package/Webex.rpm"
WEBEX_RPM="Webex.rpm"
WEBEX_PUBLIC_KEY_URL="https://binaries.webex.com/WebexDesktop-CentOS-Official-Package/webex_public.key"
WEBEX_PUBLIC_KEY="webex_public.key"
WEBEX_HASH_URL="https://binaries.webex.com/WebexDesktop-CentOS-Official-Package/webex.rpm.sha512sum"
WEBEX_HASH="webex.rpm.sha512sum"
USER_AGENT="Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0"

# Function to handle download with retries and headers
download_file() {
  local url="$1"
  local output="$2"
  local retries=3
  local count=0

  echo "Downloading $output from $url..."
  while [ $count -lt $retries ]; do
    if curl -L -A "$USER_AGENT" -H "Accept: */*" -o "$output" "$url" --fail; then
      echo "Download successful."
      return 0
    else
      echo "Download failed. Retrying ($((count + 1))/$retries)..."
      ((count++))
      sleep 2
    fi
  done
  echo "Error: Failed to download $output after $retries attempts. Access Denied or resource unavailable."
  echo "Please check the URL, network connection, or try downloading via a browser and inspect the request."
  return 1
}

# Step 1: Download the latest Webex RPM
if ! download_file "$WEBEX_URL" "$WEBEX_RPM"; then
  echo "Proceeding with manual download instructions if RPM was downloaded separately."
  if [ ! -f "$WEBEX_RPM" ]; then
    echo "Error: Webex.rpm not found. Please download it manually from $WEBEX_URL and place it in the current directory."
    exit 1
  fi
fi

# Step 2: Download the Webex public key (optional, continue if fails)
if ! download_file "$WEBEX_PUBLIC_KEY_URL" "$WEBEX_PUBLIC_KEY"; then
  echo "Warning: Failed to download public key. Skipping key import and proceeding with installation."
  SKIP_KEY_IMPORT=1
else
  SKIP_KEY_IMPORT=0
fi

# Step 3: Download the SHA512 checksum file (optional, continue if fails)
if ! download_file "$WEBEX_HASH_URL" "$WEBEX_HASH"; then
  echo "Warning: Failed to download hash file. Skipping hash verification and proceeding with installation."
  SKIP_HASH=1
else
  SKIP_HASH=0
fi

# Step 4: Verify the hash (if downloaded)
if [ "$SKIP_HASH" -eq 0 ]; then
  echo "Verifying the RPM hash..."
  if ! sha512sum -c "$WEBEX_HASH"; then
    echo "Error: Hash verification failed. The downloaded RPM may be corrupted or tampered with."
    exit 1
  fi
else
  echo "Warning: Hash verification skipped due to missing hash file."
fi

# Step 5: Import the public key for RPM verification (if downloaded)
if [ "$SKIP_KEY_IMPORT" -eq 0 ]; then
  echo "Importing Webex public key..."
  if ! sudo rpm --import "$WEBEX_PUBLIC_KEY"; then
    echo "Warning: Failed to import public key. Proceeding with installation, but RPM signature verification may fail."
  fi
else
  echo "Warning: Public key import skipped due to missing key file."
fi

# Step 6: Install the Webex RPM using dnf
echo "Installing Webex RPM..."
if ! sudo dnf install -y "$WEBEX_RPM"; then
  echo "Error: Installation failed. Check for missing dependencies or conflicting packages."
  echo "Try running 'sudo dnf install -y ./$WEBEX_RPM' manually to see detailed error messages."
  exit 1
fi

# Step 7: Clean up downloaded files
echo "Cleaning up..."
rm -f "$WEBEX_RPM" "$WEBEX_PUBLIC_KEY" "$WEBEX_HASH"

echo "Webex installation completed successfully!"
