#!/bin/bash

set -e
# use english to be able to easily grep from expected strings
export LC_ALL=C.UTF-8
unset LANG LANGUAGE

cmd() { echo "+" "$@" ; "$@" ; }

devserie="mantic"

if ! grep -q $devserie /etc/apt/sources.list; then
  echo "you need to be on $devserie to use this script, update your apt sources definition"
  exit 1
fi

if ! grep -qr "$devserie-proposed" /etc/apt; then
  echo "* Enabling $devserie-proposed sources"
  cmd sudo add-apt-repository -S "deb http://archive.ubuntu.com/ubuntu/ $devserie-proposed universe main restricted multiverse"
  echo ""
fi

echo "* Installing the ubuntu shell extensions including tiling"
cmd sudo apt install gnome-shell-ubuntu-extensions
echo ""

echo "* Installing the new polkit daemon, it might make some of your rules invalid"
cmd sudo apt install libpolkit-agent-1-0/$devserie-proposed libpolkit-gobject-1-0/$devserie-proposed pkexec/$devserie-proposed policykit-1/$devserie-proposed polkitd/$devserie-proposed gir1.2-polkit-1.0/$devserie-proposed
echo ""

echo "* Installing dbus-broker (not removing dbus-daemon though since gdm currently depends on it)"
cmd sudo apt install dbus-broker #dbus-daemon-
echo ""

echo "* Installing the new flutter snap-store from preview/edge"
if snap list snap-store &>/dev/null; then
  cmd sudo snap refresh --channel=preview/edge snap-store
else
  cmd sudo snap install --channel=preview/edge snap-store
fi
echo ""

echo "* Installing the new flutter firmware-updater snap from edge"
cmd sudo snap install --edge firmware-updater
echo ""
