#!/bin/sh

set -e
set -x

# Open VMware tools
echo "Installing VMware Tools"

# Install 
pkg install -y pfSense-pkg-Open-VM-Tools
