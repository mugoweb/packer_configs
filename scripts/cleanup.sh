#!/bin/bash -eux

# Uninstall Ansible and remove PPA
apt -y remove --purge ansible
apt-add-repository --remove ppa:ansible/ansible

# Cleanup apt
dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs apt -y purge
[ -f /var/lib/apt/lists/lock ] && rm -f /var/lib/apt/lists/lock
apt -y autoremove
apt -y clean

# Cleanup cached interfaces
[ -f /etc/udev/rules.d/70-persistent-net.rules ] && rm -f /etc/udev/rules.d/70-persistent-net.rules

# Cleanup logs
find /var/log -type f | while read f; do echo -ne '' > $f; done

# Cleanup bash history
unset HISTFILE
rm -f $HOME/.bash_history
[ -f /root/.bash_history ] && rm /root/.bash_history

# Cleanup scripts
rm -f $HOME/*.sh

# Zero out disk
dd if=/dev/zero of=/EMPTY bs=1M 2>/dev/null
rm -f /EMPTY

sync
