#! /bin/bash
time=$(date "+%Y-%m-%d_%H-%M-%S")
dirname=/tmp/hydrominder_backup_$time
mkdir -p $dirname
cd $dirname
sudo docker exec -i postgres /usr/local/bin/pg_dumpall -U hydrominder > postgres-backup.sql
sudo cp -r /var/lib/hydrominder/ssl .
sudo cp -r /var/lib/hydrominder/var .
mkdir -p /var/lib/hydrominder/backups
tar czf /var/lib/hydrominder/backups/$time.tar.gz .
rm -r $dirname
