#!/usr/bin/env bash

# Based on https://github.com/basecamp/omarchy/blob/master/install/config/power.sh

sudo dnf install -y power-profiles-daemon

if ls /sys/class/power_supply/BAT* &>/dev/null; then
  # This computer runs on a battery
  powerprofilesctl set balanced || true
else
  # This computer runs on power outlet
  powerprofilesctl set performance || true
fi
