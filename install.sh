#! /bin/bash
clear

echo "##### Installing packages..."
sudo apt-get update > /dev/null
sudo apt-get install -y git openssl inotify-tools > /dev/null

echo "##### Creating 'hydrominder' group..."
sudo groupadd --system hydrominder > /dev/null
echo "##### Creating user that can't login, without home directory, add to 'hydrominder' group..."
sudo useradd --system -M -g hydrominder hydrominder > /dev/null

echo "##### Setting up directories..."
sudo mkdir -p /var/lib/hydrominder/scripts > /dev/null
sudo chown -R hydrominder:hydrominder /var/lib/hydrominder > /dev/null

echo "##### Cloning the whole scripts repository..."
cd /var/lib/hydrominder/scripts > /dev/null
# TODO: Overwrite existing directory
sudo git clone https://gitlab.utwente.nl/cs21-32/hydrominderscripts.git
sudo chmod ug+x /var/lib/hydrominder/scripts/*.sh > /dev/null 2>&1

echo "##### Installing Docker and required packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release > /dev/null
curl -fsSL https://get.docker.com | sudo sh -s
echo "##### Installing docker pagackes..."
sudo apt-get update > /dev/null
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose > /dev/null

echo "##### Creating self-signed SSL certificate..."
# Valid for 10 years (TODO: automatically renew this)
sudo -u hydrominder mkdir -p /var/lib/hydrominder/ssl > /dev/null

sudo openssl req -newkey rsa:2048 -x509 -sha256 -days 3650 -nodes -subj "/C=US/ST=State/L=City/O=Dis/CN=*" -keyout /var/lib/hydrominder/ssl/hydrominder.key -out /var/lib/hydrominder/ssl/hydrominder.crt > /dev/null
echo "##### Making private key rw for user..."
sudo chmod 600 /var/lib/hydrominder/ssl/hydrominder.key > /dev/null
echo "##### Making public key rw for user, r for others..."
sudo chmod 644 /var/lib/hydrominder/ssl/hydrominder.crt > /dev/null

echo "##### Generating secure 64-byte key for API cookie..."
COOKIE_SECRET=$(openssl rand -base64 32)

echo "##### Generating password for DB..."
DB_PASSWORD=$(openssl rand -base64 12)

echo "##### Generating key for Controller <-> API communication..."
API_TOKEN=$(openssl rand -base64 32)

echo "##### Creating environment variable files..."
# These should loaded when running the docker container
sudo -u hydrominder mkdir -p /var/lib/hydrominder/var > /dev/null
sudo chmod -R 600 /var/lib/hydrominder/var > /dev/null

# API env
sudo -u hydrominder cat <<EOT >> /var/lib/hydrominder/var/api.env
DB_PASSWORD=${DB_PASSWORD}
SECRET=${COOKIE_SECRET}
EOT

# Web Appenv
sudo -u hydrominder cat <<EOT >> /var/lib/hydrominder/var/webapp.env
EOT

# Controller env
sudo -u hydrominder cat <<EOT >> /var/lib/hydrominder/var/controller.env
API_TOKEN=${API_TOKEN}
EOT

# TODO: Add the /var/lib/hydrominder/git/shutdown-watcher.sh script as a systemd service

# Login DOCKER
echo "##### Authenticating docker repository..."
sudo -u hydrominder mkdir -p /var/lib/hydrominder/docker_configs > /dev/null
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_api login registry.gitlab.utwente.nl -u CLIENT -p AZuNxneL16MhQ2xsxDBv 2> /dev/null
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_app login registry.gitlab.utwente.nl -u CLIENT -p SQyRA_B2hzBXZJ9sdiUs 2> /dev/null
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_controller login registry.gitlab.utwente.nl -u CLIENT -p qV439CsvoBqdWKJ2z5-M 2> /dev/null

echo "##### Pulling containers..."
# API pull token: AZuNxneL16MhQ2xsxDBv (public)
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_api pull registry.gitlab.utwente.nl/cs21-32/hydrominder_api > /dev/null
# Web App pull token: SQyRA_B2hzBXZJ9sdiUs (public)
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_app pull registry.gitlab.utwente.nl/cs21-32/hydrominder_app > /dev/null
# Controller pull token: qV439CsvoBqdWKJ2z5-M (public)
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_controller pull registry.gitlab.utwente.nl/cs21-32/hydrominder > /dev/null

# TODO: docker-compose up -d