#!/bin/bash

#
# Preamble
#

set -e
# use english to be able to easily grep from expected strings
export LC_ALL=C.UTF-8
unset LANG LANGUAGE

target_serie="mantic"

#
# Helpers
#

GREEN="\033[1;32m"
ORANGE="\033[0;33m"
RED="\033[1;31m"
RESET="\033[0m"

info() {
  echo -e "${GREEN}INFO: $*${RESET} "
}

warn() {
  echo -e "${ORANGE}WARN: $*${RESET} "
}

error() {
  echo -e "${RED}ERROR: $*${RESET}" 1>&2
}

newline() {
  echo ""
}

#
# Functions
#

cmd() {
  newline
  info "$@" # Log the command to be run
  "$@"      # Run the command
  newline
}

welcome_message() {
  newline
  info "Thank you for testing Mantic Minotaur 🐂🏃"
  info "This script configures your machine to be as close to the final version as possible."
  newline
  warn "This is under active development so expect breakages."
  newline
}

check_environment() {
  if ! grep -q $target_serie /etc/apt/sources.list; then
    error "You need to be on $target_serie to use this script"
    exit 1
  fi
}

ask_if_user_wants_to_continue() {
  info "Mantic Minotaur detected 🥳"
  read -p "Y or y to continue: " -n 1 -r
  newline
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
}

update() {
  info "Updating OS ..."
  cmd sudo apt update && sudo apt upgrade && sudo snap refresh
}

configure_sources() {
  if ! grep -qr "$target_serie-proposed" /etc/apt; then
    info "Enabling $target_serie-proposed sources ..."
    cmd sudo add-apt-repository -S "deb http://archive.ubuntu.com/ubuntu/ $target_serie-proposed universe main restricted multiverse"
  fi
}

install_gnome_shell_extensions() {
  info "Installing the ubuntu shell extensions including tiling"
  cmd sudo apt install gnome-shell-ubuntu-extensions
}

install_polkit() {
  info "Installing the new polkit daemon"
  warn "This might make old rules invalid"
  cmd sudo apt install libpolkit-agent-1-0/$target_serie-proposed libpolkit-gobject-1-0/$target_serie-proposed pkexec/$target_serie-proposed policykit-1/$target_serie-proposed polkitd/$target_serie-proposed gir1.2-polkit-1.0/$target_serie-proposed
}

install_dbus_broker() {
  info "Installing dbus-broker (not removing dbus-daemon though since gdm currently depends on it)"
  cmd sudo apt install dbus-broker #dbus-daemon-
}

install_app_store() {
  if snap list snap-store &>/dev/null; then
    info "Refreshing the app store from preview/edge"
    cmd sudo snap refresh --channel=preview/edge snap-store
  else
    info "Installing the app store from preview/edge"
    cmd sudo snap install --channel=preview/edge snap-store
  fi
}

install_firmware_updater() {
  info "Installing the new flutter firmware-updater snap from edge"
  cmd sudo snap install --edge firmware-updater
}

main() {
  welcome_message
  check_environment
  ask_if_user_wants_to_continue
  update
  configure_sources
  install_gnome_shell_extensions
  install_polkit
  install_dbus_broker
  install_app_store
  install_firmware_updater
}

main
