#!/bin/sh

set -e
set -x

# Virtualbox additions
echo "Installing Virtualbox Additions"

# Install
sudo pkg install -y dbus
# no native pkg was available from pfsense so i had to pull directly from
# freebsd10 pkg repo
sudo pkg add http://pkg.freebsd.org/freebsd:10:x86:64/latest/All/virtualbox-ose-additions-nox11-5.1.22_1.txz

if [ $? -eq 0 ] ; then 
    echo "adding virtrualbox guest modules to rc.conf"
# adding modules to /etc/rc.conf 
    sudo tee -a /etc/rc.conf <<EOF
vboxguest_enable="YES"
vboxservice_enable="YES"
EOF
fi
