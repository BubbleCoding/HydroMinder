# /bin/bash

# This script will watch for changes in the update file using inotify and will run the update script if the contents are 'true'
echo "waiting" | sudo tee /var/lib/hydrominder/update_signal
sudo echo "waiting" > /var/lib/hydrominder/update_signal
while inotifywait -e close_write /var/lib/hydrominder/update_signal; do
    if [ -f /var/lib/hydrominder/update_signal ]; then
        if [ "$(cat /var/lib/hydrominder/update_signal)" = "true" ]; then
            # update the containers
            echo "Updating HydroMinder..."
            curl -fsSL https://gitlab.utwente.nl/cs21-32/hydrominderscripts/-/raw/master/update.sh | sudo bash -s
            echo "waiting" | sudo tee /var/lib/hydrominder/update_signal
        fi
    fi
done