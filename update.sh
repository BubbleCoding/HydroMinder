#! /bin/bash
clear

cd /var/lib/hydrominder/scripts/
echo "##### Pulling container updates..."
sudo docker-compose pull

echo "##### Restarting containers..."
sudo docker-compose restart
