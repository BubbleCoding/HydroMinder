#! /bin/bash
INSTALL_DIR="/var/lib/hydrominder"
SCRIPTS_DIR="$INSTALL_DIR/scripts"

sudo systemctl disable signals-watcher.service
sudo systemctl stop signals-watcher.service