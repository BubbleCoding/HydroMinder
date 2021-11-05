#! /bin/bash
INSTALL_DIR="/var/lib/hydrominder"
SCRIPTS_DIR="$INSTALL_DIR/scripts"

sudo -u hydrominder touch $INSTALL_DIR/shutdown_signal
sudo -u hydrominder touch $INSTALL_DIR/update_signal

sudo systemctl enable $SCRIPTS_DIR/signal-watchers/shutdown-watcher.service
sudo systemctl start shutdown-watcher.service
sudo systemctl enable $SCRIPTS_DIR/signal-watchers/update-watcher.service
sudo systemctl start update-watcher.service

sudo systemctl daemon-reload
