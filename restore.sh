#! /bin/bash
if [[ -f "$1" ]]
then
    echo "##### Valid file: ${1}"
    FILENAME=$(echo $1 | awk -F "/" '{print $NF}')
    FILENAME=$(printf '%s\n' "${FILENAME%.*}")
    TMP_DIR="/tmp/$filename"
    INSTALL_DIR="/var/lib/hydrominder"
    mkdir $TMP_DIR
    cd $INSTALL_DIR/scripts
    sudo docker-compose stop
    cd $TMP_DIR
    tar -xf $1
    rm -rf $INSTALL_DIR/ssl
    rm -rf $INSTALL_DIR/var
    mv ssl $INSTALL_DIR
    mv var $INSTALL_DIR
    cd $INSTALL_DIR/scripts
    sudo docker-compose up -d
    sudo docker exec postgres pg_restore -U hydrominder $TMP_DIR/postgres-backup.sql 
else
    echo "##### Not a file: ${1}"
fi
