#!/bin/sh

set -e
set -x

if ! grep -q "UseDNS no" /etc/ssh/sshd_config 
then 
    echo appending \'UseDNS no\' to sshd_config file
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
    sudo tee -a /etc/ssh/sshd_config <<EOF
UseDNS no
EOF
fi
