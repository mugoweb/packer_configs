#!/bin/bash -eux

# Update apt and upgrade base packages
apt update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq

# Disable daily apt unattended updates
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic
