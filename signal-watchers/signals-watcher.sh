# /bin/bash

# This script will watch for changes signals and act accordingly.
echo "waiting" | sudo tee /var/lib/hydrominder/signals
while inotifywait -e close_write /var/lib/hydrominder/signals; do
    if [ -f /var/lib/hydrominder/signals ]; then
        CONTENT = "$(cat /var/lib/hydrominder/signals)"
        # split on '::::::::::' https://stackoverflow.com/a/5257398
        SPLIT=(${CONTENT//\:\:\:\:\:\:\:\:\:\:/ })
        ACTION=${SPLIT[0]}
        PARAM1=${SPLIT[1]}
        PARAM2=${SPLIT[1]}
        if [ $ACTION = "shutdown" ]; then
            echo "Shutting down..."
            sudo shutdown -h now
        else if [ $ACTION = "update" ]; then
            echo "Updating HydroMinder..."
            curl -fsSL https://gitlab.utwente.nl/cs21-32/hydrominderscripts/-/raw/master/update.sh | sudo bash -s
        else if [ $ACTION = "backup" ]; then
            echo "Backing up HydroMinder..."
            sudo /var/lib/hydrominder/backup.sh $PARAM1 $PARAM2
        else if [ $ACTION = "restore" ]; then
            echo "Restoring HydroMinder..."
            sudo /var/lib/hydrominder/restore.sh $PARAM1 $PARAM2
        fi
        echo "waiting" | sudo tee /var/lib/hydrominder/signals
    fi
done