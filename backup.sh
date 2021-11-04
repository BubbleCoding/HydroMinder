#! /bin/bash
time=$(date "+%Y-%m-%d_%H-%M-%S")
dirname=/tmp/hydrominder_backup_$time
mkdir -p $dirname
INSTALL_DIR="/var/lib/hydrominder"
cd $dirname
sudo docker exec -i postgres /usr/local/bin/pg_dumpall -U hydrominder > postgres-backup.sql
sudo cp -r $INSTALL_DIR/ssl .
sudo cp -r $INSTALL_DIR/var .
BACKUP_DIR="$INSTALL_DIR/backups"
mkdir -p $BACKUP_DIR
tar czf $BACKUP_DIR/$time.tar.gz *
rm -r $dirname
