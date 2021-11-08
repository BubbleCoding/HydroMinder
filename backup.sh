#! /bin/bash
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters. Usage: ./backup.sh filename.tar.gz"
else
    dirname=/tmp/hydrominder_backup_$1
    mkdir -p $dirname
    INSTALL_DIR="/var/lib/hydrominder"
    cd $dirname
    sudo docker exec -i postgres /usr/local/bin/pg_dumpall -U hydrominder > postgres-backup.sql
    sudo cp -r $INSTALL_DIR/ssl .
    sudo cp -r $INSTALL_DIR/var .
    BACKUP_DIR="$INSTALL_DIR/backups"
    mkdir -p $BACKUP_DIR
    tar czf $BACKUP_DIR/$1 *
    rm -r $dirname
fi
