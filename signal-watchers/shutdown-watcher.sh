# /bin/bash

# This script will watch for changes in the shutdown file using inotify and will shutdown the machine if the contents are 'true'
echo "waiting" | sudo tee /var/lib/hydrominder/shutdown_signal
while inotifywait -e close_write /var/lib/hydrominder/shutdown_signal; do
    if [ -f /var/lib/hydrominder/shutdown_signal ]; then
        if [ "$(cat /var/lib/hydrominder/shutdown_signal)" = "true" ]; then
            # shutdown the machine
            echo "Shutting down..."
            sudo shutdown -h now
echo "waiting" | sudo tee /var/lib/hydrominder/shutdown_signal
        fi
    fi
done
