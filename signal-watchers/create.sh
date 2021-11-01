#! /bin/bash

sudo systemctl stop signal-watcher.target
sudo systemctl disable $SCRIPTS_DIR/signal-watchers/shutdown-watcher.service
sudo systemctl disable $SCRIPTS_DIR/signal-watchers/update-watcher.service

sudo systemctl enable $SCRIPTS_DIR/signal-watchers/shutdown-watcher.service
sudo systemctl enable $SCRIPTS_DIR/signal-watchers/update-watcher.service
sudo systemctl start signal-watcher.target