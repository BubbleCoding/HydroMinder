# /bin/bash

# This script will watch for changes in the shutdown file using inotify and will shutdown the machine if the contents are 'true'
sudo echo "waiting" > /var/lib/hydrominder/shutdown.txt
while inotifywait -e modify /var/lib/hydrominder/shutdown.txt; do
    if [ -f /var/lib/hydrominder/shutdown.txt ]; then
        if [ "$(cat /var/lib/hydrominder/shutdown.txt)" = "true" ]; then
            # shutdown the machine
            echo "Shutting down..."
            sudo shutdown -h now
        fi
    fi
done