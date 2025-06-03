#!/bin/bash


# Ensure required directories exist for volume mapping
if [ ! -d "/tmp/backups" ]; then
  mkdir /tmp/backups
fi
if [ ! -d "/var/lib/db-volume/mysql" ]; then
  mkdir -p /var/lib/db-volume/mysql
  chmod +w /var/lib/db-volume/mysql
fi
if [ ! -d "/var/lib/openmrs-volume/openmrs-data" ]; then
  mkdir -p /var/lib/openmrs-volume/openmrs-data
  chmod +w /var/lib/openmrs-volume/openmrs-data
fi

if [ ! -d "/var/lib/certs/letscencrypt" ]; then
  mkdir -p /var/lib/certs/letscencrypt
  chmod +w /var/lib/certs/letscencrypt
fi

##
# iSantePlus DB
##
# Load Env vars from package-metadata.json file
filepath="./packages/database-mysql/package-metadata.json"
envs=$(jq -r '.environmentVariables | to_entries | .[] | "\(.key)=\(.value)"' $filepath)

# Export each environment variable
while IFS= read -r line; do
  export "$line"
done <<< "$envs"

# Build the Docker image
docker build -t isanteplus-mysql:local ./projects/isanteplus-db
docker build -t isanteplus-mysql:legacy ./projects/isanteplus-db -f ./projects/isanteplus-db/legacy.Dockerfile
docker build -t isanteplus-mysql:2.8.4 ./projects/isanteplus-db -f ./projects/isanteplus-db/legacy.Dockerfile

##
# iSantePlus Application
## 

## Modules

# Lab Integration Module


# Load Env vars from json file environmentVariables field
filepath="./packages/emr-isanteplus/package-metadata.json"
envs=$(jq -r '.environmentVariables | to_entries | .[] | "\(.key)=\(.value)"' $filepath)

# Export each environment variable
while IFS= read -r line; do
  export "$line"
done <<< "$envs"

docker build -t itechuw/docker-isanteplus-server:local ./projects/emr-isanteplus -f ./projects/emr-isanteplus/Dockerfile
# docker build -t itechuw/docker-isanteplus-server:legacy ./projects/emr-isanteplus -f ./projects/emr-isanteplus/legacy.Dockerfile
# docker build -t itechuw/docker-isanteplus-server:2.8.4 ./projects/emr-isanteplus -f ./projects/emr-isanteplus/2_8_4.Dockerfile

##
# Cert Maintenance
##
# Load Env vars from json file environmentVariables field
filepath="./packages/reverse-proxy-nginx/package-metadata.json"

envs=$(jq -r '.environmentVariables | to_entries | .[] | "\(.key)=\(.value)"' $filepath)

# Export each environment variable
while IFS= read -r line; do
  export "$line"
done <<< "$envs"

# Build the Docker image
docker build -t cert-maintenance:local ./projects/cert-maintenance

##
# Build the Platform to contain the above custom builds
##
./build-image.sh

echo "You can run the the Platform commands: E.g: ./instant-linux package init -p dev"
