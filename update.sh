#! /bin/bash
clear

INSTALL_DIR="/var/lib/hydrominder"
SCRIPTS_DIR="$INSTALL_DIR/scripts"

cd $SCRIPTS_DIR
echo "##### Updating scripts..."
# git reset hard and pull
sudo git reset --hard
# chmod all scripts again
sudo chmod ug+x $SCRIPTS_DIR/*.sh > /dev/null 2>&1
# git pull
sudo git pull

# recreate signal-watcher.sh service
sudo systemctl disable signal-watcher.service
sudo systemctl enable $SCRIPTS_DIR/signal-watcher.service
sudo systemctl start signal-watcher.service

# pull the containers
./pull-containers.sh

echo "##### Restarting containers..."
sudo docker-compose restart
