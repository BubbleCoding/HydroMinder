#! /bin/bash

INSTALL_DIR="/var/lib/hydrominder"
VAR_DIR="$INSTALL_DIR/var"

echo "##### Pulling containers (this might take a while)..."
# API pull token
sudo docker --config $INSTALL_DIR/docker_configs/.hydrominder_api pull registry.gitlab.utwente.nl/cs21-32/hydrominder_api:latest > /dev/null
# Web App pull
sudo docker --config $INSTALL_DIR/docker_configs/.hydrominder_app pull registry.gitlab.utwente.nl/cs21-32/hydrominder_app:latest > /dev/null
# Controller pull 
sudo docker --config $INSTALL_DIR/docker_configs/.hydrominder_controller pull registry.gitlab.utwente.nl/cs21-32/hydrominder:32bit > /dev/null

DOCKER_DIGEST_hydrominder_api=$(sudo docker images -q --no-trunc registry.gitlab.utwente.nl/cs21-32/hydrominder_api:latest | sed 's/sha256://g')
DOCKER_DIGEST_hydrominder_app=$(sudo docker images -q --no-trunc registry.gitlab.utwente.nl/cs21-32/hydrominder_app:latest | sed 's/sha256://g')
DOCKER_DIGEST_hydrominder=$(sudo docker images -q --no-trunc registry.gitlab.utwente.nl/cs21-32/hydrominder:32bit | sed 's/sha256://g')
# Docker digests env
sudo -u hydrominder touch $VAR_DIR/docker_digests.env
sudo -u hydrominder tee $VAR_DIR/docker_digests.env <<EOT > /dev/null
DOCKER_DIGEST_hydrominder_api=${DOCKER_DIGEST_hydrominder_api}
DOCKER_DIGEST_hydrominder_app=${DOCKER_DIGEST_hydrominder_app}
DOCKER_DIGEST_hydrominder=${DOCKER_DIGEST_hydrominder}
EOT