#! /bin/bash
INSTALL_DIR="/var/lib/hydrominder"
SCRIPTS_DIR="$INSTALL_DIR/scripts"

sudo systemctl disable shutdown-watcher.service
sudo systemctl disable update-watcher.service

sudo systemctl enable $SCRIPTS_DIR/signal-watchers/shutdown-watcher.service
sudo systemctl enable $SCRIPTS_DIR/signal-watchers/update-watcher.service
