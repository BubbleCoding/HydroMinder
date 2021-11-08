#! /bin/bash
INSTALL_DIR="/var/lib/hydrominder"
SCRIPTS_DIR="$INSTALL_DIR/scripts"

sudo -u hydrominder touch $INSTALL_DIR/signals

sudo systemctl enable $SCRIPTS_DIR/signal-watchers/signals-watcher.service
sudo systemctl start signals-watcher.service

sudo systemctl daemon-reload
