#!/usr/bin/env bash

sudo -v
if [ $? -ne 0 ]; then
    echo "\nThis script requires sudo privs..."
    exit 1
fi
