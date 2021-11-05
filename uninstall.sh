#! /bin/sh
echo "##### Uninstalling hydrominder"
read -r -p "Are You Sure? [y/N] " input
 
case $input in
    [yY][eE][sS]|[yY])
    echo "##### Stopping hydrominder..."
    cd /var/lib/hydrominder/scripts && sudo docker-compose stop
    echo "##### Removing docker containers, volumes, etc..."
    sudo docker system prune -af > /dev/null
    sudo docker volume prune -f > /dev/null
    echo "##### Removing files..."
    cd /var/lib
    sudo rm -rf /var/lib/hydrominder
    sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg
    sudo rm -f /etc/apt/sources.list.d/docker.list
    echo "##### Removing user..."
    sudo userdel hydrominder > /dev/null
    echo "##### Removing services..."
    sudo ./signal-watchers.destroy.sh > /dev/null
 ;;
    [nN][oO]|[nN]|'')
 echo "##### Cancelling..."
       ;;
    *)
 echo "##### Invalid input..."
 exit 1
 ;;
esac
