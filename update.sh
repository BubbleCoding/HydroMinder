#! /bin/bash
clear

cd /var/lib/hydrominder/scripts/
echo "##### Updating scripts..."
# git reset hard and pull
sudo git reset --hard && sudo git pull
# chmod all scripts again
sudo chmod ug+x /var/lib/hydrominder/scripts/*.sh > /dev/null 2>&1

# TODO: restart shutdown-watcher.sh

echo "##### Pulling container updates..."
sudo docker-compose pull

echo "##### Restarting containers..."
sudo docker-compose restart
