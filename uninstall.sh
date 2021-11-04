#! /bin/sh
echo "##### Uninstalling hydrominder"
echo "WARNING: This will prune -a the docker systems and prune docker volumes, therefore deleting all containers which are turned off and their associated data."
read -r -p "Are You Sure? [y/N] " input

case $input in
    [yY][eE][sS]|[yY])
    INSTALL_DIR="/var/lib/hydrominder"
    if [[ -d "$INSTALL_DIR" ]]
    then
      echo "##### Stopping hydrominder..."
      cd $INSTALL_DIR/scripts && sudo docker-compose stop
    fi
    echo "##### Removing docker containers, volumes, etc..."
    sudo docker system prune -af > /dev/null
    sudo docker volume prune -f > /dev/null
    echo "##### Removing files..."
    cd $INSTALL_DIR/..
    sudo rm -rf $INSTALL_DIR
    echo "##### Removing user..."
    sudo userdel hydrominder 2> /dev/null
 ;;
    [nN][oO]|[nN]|'')
 echo "##### Cancelling..."
       ;;
    *)
 echo "##### Invalid input..."
 exit 1
 ;;
esac
