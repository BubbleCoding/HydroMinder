#! /bin/bash
clear

INSTALL_DIR="/var/lib/hydrominder"
SCRIPTS_DIR="$INSTALL_DIR/scripts"

cd $SCRIPTS_DIR
echo "##### Updating scripts..."
# git reset hard and pull
sudo git reset --hard && sudo git pull
# chmod all scripts again
find $SCRIPTS_DIR -type f -name "*.sh" | xargs sudo chmod ug+x

# recreate signal-watcher.sh service
sudo ./signal-watchers/create.sh

# pull the containers
sudo ./pull-containers.sh

echo "##### Restarting containers..."
sudo docker-compose up -d