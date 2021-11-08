#! /bin/bash
clear

INSTALL_DIR="/var/lib/hydrominder"
SCRIPTS_DIR="$INSTALL_DIR/scripts"
VAR_DIR="$INSTALL_DIR/var"
SSL_DIR="$INSTALL_DIR/ssl"

echo "##### Installing packages..."
sudo apt-get update > /dev/null
sudo apt-get install -y git openssl pass inotify-tools > /dev/null

echo "##### Creating 'hydrominder' group..."
sudo groupadd --system hydrominder > /dev/null
echo "##### Creating user that can't login, without home directory, add to 'hydrominder' group..."
sudo useradd --system -M -g hydrominder hydrominder > /dev/null

echo "##### Setting up directories..."
sudo mkdir -p $INSTALL_DIR > /dev/null
sudo chown -R hydrominder:hydrominder $INSTALL_DIR > /dev/null

echo "##### Cloning the whole scripts repository..."
cd $INSTALL_DIR
sudo git clone https://gitlab.utwente.nl/cs21-32/hydrominderscripts.git $SCRIPTS_DIR
cd $SCRIPTS_DIR
sudo git reset --hard && sudo git pull > /dev/null
find $SCRIPTS_DIR -type f -name "*.sh" | xargs sudo chmod ug+x

echo "##### Installing Docker and required packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release > /dev/null
echo "##### Adding repository..."
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "##### Installing docker packages..."
sudo apt-get update > /dev/null
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose > /dev/null

if sudo [ ! -f $SSL_DIR/hydrominder.key ]; then
    # this cert should NEVER change, except if it expired
    echo "##### Creating self-signed SSL certificate..."
    # Valid for 10 years (TODO: automatically renew this)
    sudo -u hydrominder mkdir -p $SSL_DIR > /dev/null

    touch $SSL_DIR/hydrominder.key
    touch $SSL_DIR/hydrominder.crt
    echo "##### Making private key rw for user..."
    sudo chmod 600 $SSL_DIR/hydrominder.key > /dev/null
    echo "##### Making public key rw for user, r for others..."
    sudo chmod 644 $SSL_DIR/hydrominder.crt > /dev/null
    echo "##### Generating key..."
    sudo openssl req -newkey rsa:2048 -x509 -sha256 -days 3650 -nodes -subj "/C=US/ST=State/L=City/O=Dis/CN=*" -keyout $SSL_DIR/hydrominder.key -out $SSL_DIR/hydrominder.crt > /dev/null
fi
SSL_FINGERPRINT=$(openssl x509 -noout -fingerprint -sha256 -inform pem -in $SSL_DIR/hydrominder.crt | cut -d "=" -f2 | tr -d :)

echo "##### Generating password for DB..."
DB_PASSWORD=$(openssl rand -base64 12)

echo "##### Generating key for Controller <-> API communication..."
API_TOKEN=$(openssl rand -base64 32)

# Create directory to store env variables
sudo -u hydrominder mkdir -p $VAR_DIR > /dev/null
sudo chmod -R 700 $VAR_DIR > /dev/null

if sudo [ ! -f $VAR_DIR/api_cookie.env ]; then
    # this cookie secret should NEVER change
    echo "##### Generating secure 64-byte key for API cookie..."
    COOKIE_SECRET=$(openssl rand -base64 32)
    sudo -u hydrominder touch $VAR_DIR/api_cookie.env
    sudo -u hydrominder tee $VAR_DIR/api_cookie.env <<EOT > /dev/null
SECRET=${COOKIE_SECRET}
EOT
fi

# DB env
if sudo [ ! -f $VAR_DIR/db.env ]; then
    # this should NEVER change
    sudo -u hydrominder touch $VAR_DIR/db.env
    sudo -u hydrominder tee $VAR_DIR/db.env <<EOT  > /dev/null
POSTGRES_DB=hydrominder
POSTGRES_USER=hydrominder
POSTGRES_PASSWORD=${DB_PASSWORD}
EOT
fi

GITLAB_HYDROMINDER_API_TOKEN=9PATcQD3EYCRf8K5iaTX
GITLAB_HYDROMINDER_APP_TOKEN=dPzRPw8tiTLVnsSL3GiH
GITLAB_HYDROMINDER_TOKEN=q3RZYyqNPRLsCsXjNiBz

# API env
sudo -u hydrominder touch $VAR_DIR/api.env
sudo -u hydrominder tee $VAR_DIR/api.env <<EOT > /dev/null
DB_HOST=postgres
DB_PORT=5432
GITLAB_HYDROMINDER_API_TOKEN=${GITLAB_HYDROMINDER_API_TOKEN}
GITLAB_HYDROMINDER_APP_TOKEN=${GITLAB_HYDROMINDER_APP_TOKEN}
GITLAB_HYDROMINDER_TOKEN=${GITLAB_HYDROMINDER_TOKEN}
EOT

# Web App env
sudo -u hydrominder touch $VAR_DIR/webapp.env
sudo -u hydrominder tee $VAR_DIR/webapp.env <<EOT > /dev/null
EOT

# Controller_token env
sudo -u hydrominder touch $VAR_DIR/controller_token.env
sudo -u hydrominder tee $VAR_DIR/controller_token.env <<EOT > /dev/null
API_CONTROLLER_TOKEN=${API_TOKEN}
EOT

echo 
echo In order to configure the scale correctly, please follow these instructions to determine the reference unit for your weight sensor:
echo https://example.com/docs/scale
read -p "Weight sensor reference unit (integer): " USER_SCALE </dev/tty
echo 

# Controller env
sudo -u hydrominder touch $VAR_DIR/controller.env
sudo -u hydrominder tee $VAR_DIR/controller.env <<EOT > /dev/null
ENV=production
REFERENCE_UNIT=${USER_SCALE}

API_URL=http://api:3001
# use userid=1 only for now
USER_ID=1

SSL_FINGERPRINT=${SSL_FINGERPRINT}
EOT

# Add the signal-watchers as systemd services
sudo ./signal-watchers/create.sh

# Login DOCKER
echo "##### Authenticating docker repository..."
sudo -u hydrominder mkdir -p $INSTALL_DIR/docker_configs > /dev/null
sudo docker --config $INSTALL_DIR/docker_configs/.hydrominder_api login registry.gitlab.utwente.nl -u CLIENT -p ${GITLAB_HYDROMINDER_API_TOKEN} 2> /dev/null
sudo docker --config $INSTALL_DIR/docker_configs/.hydrominder_app login registry.gitlab.utwente.nl -u CLIENT -p ${GITLAB_HYDROMINDER_APP_TOKEN} 2> /dev/null
sudo docker --config $INSTALL_DIR/docker_configs/.hydrominder_controller login registry.gitlab.utwente.nl -u CLIENT -p ${GITLAB_HYDROMINDER_TOKEN} 2> /dev/null

# pull the containers
sudo ./pull-containers.sh

echo "##### Starting docker compose..."
sudo docker-compose up -d
