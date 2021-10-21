# /bin/bash

# This script will watch for changes in the shutdown file using inotify and will shutdown the machine if the contents are 'true'
sudo echo "waiting" > /var/lib/hydrominder/shutdown_signal
while inotifywait -e close_write /var/lib/hydrominder/shutdown_signal; do
    if [ -f /var/lib/hydrominder/shutdown_signal ]; then
        if [ "$(cat /var/lib/hydrominder/shutdown_signal)" = "true" ]; then
            # shutdown the machine
            echo "Shutting down..."
            sudo shutdown -h now
            sudo echo "waiting" > /var/lib/hydrominder/shutdown_signal
        fi
    fi
done &

# This script will watch for changes in the update file using inotify and will run the update script if the contents are 'true'
sudo echo "waiting" > /var/lib/hydrominder/update_signal
while inotifywait -e close_write /var/lib/hydrominder/update_signal; do
    if [ -f /var/lib/hydrominder/update_signal ]; then
        if [ "$(cat /var/lib/hydrominder/update_signal)" = "true" ]; then
            # update the containers
            echo "Updating HydroMinder..."
            sudo ./var/lib/hydrominder/scipts/update.sh
            sudo echo "waiting" > /var/lib/hydrominder/update_signal
        fi
    fi
done &

wait