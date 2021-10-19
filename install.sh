#! /bin/bash
clear

echo "##### Installing packages..."
sudo apt-get update > /dev/null
sudo apt-get install -y git openssl pass inotify-tools > /dev/null

echo "##### Creating 'hydrominder' group..."
sudo groupadd --system hydrominder > /dev/null
echo "##### Creating user that can't login, without home directory, add to 'hydrominder' group..."
sudo useradd --system -M -g hydrominder hydrominder > /dev/null

echo "##### Setting up directories..."
sudo mkdir -p /var/lib/hydrominder > /dev/null
sudo chown -R hydrominder:hydrominder /var/lib/hydrominder > /dev/null

echo "##### Cloning the whole scripts repository..."
cd /var/lib/hydrominder/
# TODO: Overwrite existing directory
sudo git clone https://gitlab.utwente.nl/cs21-32/hydrominderscripts.git scripts
cd /var/lib/hydrominder/scripts/
sudo git reset --hard && sudo git pull > /dev/null
sudo chmod ug+x /var/lib/hydrominder/scripts/*.sh > /dev/null 2>&1

echo "##### Installing Docker and required packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release > /dev/null
echo "##### Adding GPG key..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "##### Installing docker packages..."
sudo apt-get update > /dev/null
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose > /dev/null

if [ ! -f /var/lib/hydrominder/ssl/hydrominder.key ]; then
    # this cert should NEVER change, except if it expired
    echo "##### Creating self-signed SSL certificate..."
    # Valid for 10 years (TODO: automatically renew this)
    sudo -u hydrominder mkdir -p /var/lib/hydrominder/ssl > /dev/null

    touch /var/lib/hydrominder/ssl/hydrominder.key
    touch /var/lib/hydrominder/ssl/hydrominder.crt
    echo "##### Making private key rw for user..."
    sudo chmod 600 /var/lib/hydrominder/ssl/hydrominder.key > /dev/null
    echo "##### Making public key rw for user, r for others..."
    sudo chmod 644 /var/lib/hydrominder/ssl/hydrominder.crt > /dev/null
    echo "##### Generating key..."
    sudo openssl req -newkey rsa:2048 -x509 -sha256 -days 3650 -nodes -subj "/C=US/ST=State/L=City/O=Dis/CN=*" -keyout /var/lib/hydrominder/ssl/hydrominder.key -out /var/lib/hydrominder/ssl/hydrominder.crt > /dev/null
fi

echo "##### Generating password for DB..."
DB_PASSWORD=$(openssl rand -base64 12)

echo "##### Generating key for Controller <-> API communication..."
API_TOKEN=$(openssl rand -base64 32)

# Create directory to store env variables
sudo -u hydrominder mkdir -p /var/lib/hydrominder/var > /dev/null
sudo chmod -R 700 /var/lib/hydrominder/var > /dev/null

if [ ! -f /var/lib/hydrominder/var/api_cookie.env ]; then
    # this cookie secret should NEVER change
    echo "##### Generating secure 64-byte key for API cookie..."
    COOKIE_SECRET=$(openssl rand -base64 32)

    # Controller env
    sudo -u hydrominder tee /var/lib/hydrominder/var/api_cookie.env <<EOT > /dev/null
SECRET=${COOKIE_SECRET}
EOT
fi

echo "##### Creating environment variable files..."
# DB env
sudo -u hydrominder tee /var/lib/hydrominder/var/db.env <<EOT  > /dev/null
POSTGRES_DB=hydrominder
POSTGRES_USER=hydrominder
POSTGRES_PASSWORD=${DB_PASSWORD}
EOT

# API env
sudo -u hydrominder tee /var/lib/hydrominder/var/api.env <<EOT > /dev/null
DB_HOST=postgres
DB_PORT=5432
EOT

# Web App env
sudo -u hydrominder tee /var/lib/hydrominder/var/webapp.env <<EOT > /dev/null
EOT

# Controller env
sudo -u hydrominder tee /var/lib/hydrominder/var/controller_token.env <<EOT > /dev/null
API_CONTROLLER_TOKEN=${API_TOKEN}
EOT

# TODO: Add the /var/lib/hydrominder/git/shutdown-watcher.sh script as a systemd service

# Login DOCKER
echo "##### Authenticating docker repository..."
sudo -u hydrominder mkdir -p /var/lib/hydrominder/docker_configs > /dev/null
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_api login registry.gitlab.utwente.nl -u CLIENT -p AZuNxneL16MhQ2xsxDBv 2> /dev/null
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_app login registry.gitlab.utwente.nl -u CLIENT -p SQyRA_B2hzBXZJ9sdiUs 2> /dev/null
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_controller login registry.gitlab.utwente.nl -u CLIENT -p qV439CsvoBqdWKJ2z5-M 2> /dev/null

# pull the containers
sudo ./pull-containers.sh

echo "##### Starting docker compose..."
sudo docker-compose up -d
