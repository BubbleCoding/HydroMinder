#! /bin/bash
INSTALL_DIR="/var/lib/hydrominder"
SCRIPTS_DIR="$INSTALL_DIR/scripts"

sudo systemctl disable shutdown-watcher.service
sudo systemctl stop shutdown-watcher.service
sudo systemctl disable update-watcher.service
sudo systemctl stop update-watcher.service