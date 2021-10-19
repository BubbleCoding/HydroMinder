#! /bin/bash

echo "##### Pulling containers (this might take a while)..."
# API pull token: AZuNxneL16MhQ2xsxDBv (public)
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_api pull registry.gitlab.utwente.nl/cs21-32/hydrominder_api > /dev/null
# Web App pull token: SQyRA_B2hzBXZJ9sdiUs (public)
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_app pull registry.gitlab.utwente.nl/cs21-32/hydrominder_app > /dev/null
# Controller pull token: qV439CsvoBqdWKJ2z5-M (public)
sudo docker --config /var/lib/hydrominder/docker_configs/.hydrominder_controller pull registry.gitlab.utwente.nl/cs21-32/hydrominder > /dev/null