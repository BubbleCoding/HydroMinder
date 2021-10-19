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
cd /var/lib/hydrominder/ > /dev/null
# TODO: Overwrite existing directory
sudo git clone https://gitlab.utwente.nl/cs21-32/hydrominderscripts.git scripts
sudo chmod ug+x /var/lib/hydrominder/scripts/*.sh > /dev/null 2>&1
cd /var/lib/hydrominder/scripts/

echo "##### Installing Docker and required packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release > /dev/null
echo "##### Adding GPG key..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "##### Installing docker packages..."
sudo apt-get update > /dev/null
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose > /dev/null

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

echo "##### Generating secure 64-byte key for API cookie..."
COOKIE_SECRET=$(openssl rand -base64 32)

echo "##### Generating password for DB..."
DB_PASSWORD=$(openssl rand -base64 12)
DB_HOST="postgres"
export $DB_HOST

echo "##### Generating key for Controller <-> API communication..."
API_TOKEN=$(openssl rand -base64 32)

echo "##### Creating environment variable files..."
# These should loaded when running the docker container
sudo -u hydrominder mkdir -p /var/lib/hydrominder/var > /dev/null
sudo chmod -R 700 /var/lib/hydrominder/var > /dev/null

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
SECRET=${COOKIE_SECRET}
EOT

# Web App env
sudo -u hydrominder tee /var/lib/hydrominder/var/webapp.env <<EOT > /dev/null
EOT

# Controller env
sudo -u hydrominder tee /var/lib/hydrominder/var/controller.env <<EOT > /dev/null
API_TOKEN=${API_TOKEN}
EOT

# TODO: Add the /var/lib/hydrominder/git/shutdown-watcher.sh script as a systemd service

# Login DOCKER
echo "##### Authenticating docker repository..."
sudo -u hydrominder mkdir -p /var/lib/hydrominder/docker_configs > /dev/null
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_api login registry.gitlab.utwente.nl -u CLIENT -p AZuNxneL16MhQ2xsxDBv 2> /dev/null
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_app login registry.gitlab.utwente.nl -u CLIENT -p SQyRA_B2hzBXZJ9sdiUs 2> /dev/null
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_controller login registry.gitlab.utwente.nl -u CLIENT -p qV439CsvoBqdWKJ2z5-M 2> /dev/null

# pull the containers
./pull-containers.sh

echo "##### Starting docker compose..."
sudo docker-compose up -d
