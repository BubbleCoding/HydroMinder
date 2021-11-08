#! /bin/bash
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters. Usage: ./restore.sh filename.zip password"
else
    INSTALL_DIR="/var/lib/hydrominder"
    FILE=$INSTALL_DIR/backups/$1
    if [[ -f "$FILE" ]]
    then
        echo "##### Valid file: ${1}"
        FILENAME=$(printf '%s\n' "${1%.*}")
        TMP_DIR="/tmp/$filename"
        mkdir $TMP_DIR
        cd $INSTALL_DIR/scripts
        sudo docker-compose stop
        cd $TMP_DIR
        unzip -P $FILE
        rm -rf $INSTALL_DIR/ssl
        rm -rf $INSTALL_DIR/var
        mv ssl $INSTALL_DIR
        mv var $INSTALL_DIR
        cd $INSTALL_DIR/scripts
        sudo docker-compose up -d
        sudo docker exec postgres pg_restore -U hydrominder $TMP_DIR/postgres-backup.sql
        rm $TMP_DIR
    else
        echo "##### Not a file: ${1}"
    fi
fi
