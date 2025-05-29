#!/bin/bash
build_and_copy_omod() {
  local project_dir="$1"
  local omod_output_dir="$2"
  local image_tag="${project_dir##*/}-build:local"
  local container_name="${project_dir##*/}-build-tmp"

  echo "Building and testing $project_dir in Docker..."
  
  # Ensure a local Maven cache directory exists
  mkdir -p "$(pwd)/.m2"
  
  docker build -t "$image_tag" "./projects/$project_dir" -f "./maven.Dockerfile"
  
  docker run --name "$container_name" \
    -v "$(pwd)/projects/$project_dir:/build" \
    -v "$(pwd)/.m2:/root/.m2" \
    -w /build \
    "$image_tag" \
    mvn clean package

  # Check if the build was successful
  if [ $? -ne 0 ]; then
    echo "Build failed for $project_dir. Exiting."
  
  else
    echo "Build succeeded for $project_dir."
    # Copy the .omod file from the container to the desired location
    #docker cp "$container_name":/build/omod/target/*.omod "$omod_output_dir/"
    # Clean up the container
  fi 

  docker rm "$container_name"
}

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

# Build the Docker image with the custom environment variables
docker build -t isanteplus-mysql:local ./projects/isanteplus-db -f ./projects/isanteplus-db/Dockerfile 
# docker build -t isanteplus-mysql:legacy ./projects/isanteplus-db -f ./projects/isanteplus-db/legacy.Dockerfile
# docker build -t isanteplus-mysql:2.8.4 ./projects/isanteplus-db -f ./projects/isanteplus-db/legacy.Dockerfile

##
# iSantePlus Application
## 

## Modules

##
# Lab Integration Module Build & Test
##
#build_and_copy_omod "openmrs-module-labintegration" "packages/emr-isanteplus/config/custom_modules"

##
# XDS Sender Module Build & Test
##
#build_and_copy_omod "openmrs-module-xds-sender" "packages/emr-isanteplus/config/custom_modules"


# echo "Building and testing openmrs-module-labintegration in Docker..."

# docker build -t labintegration-build:local ./projects/openmrs-module-labintegration -f ./projects/openmrs-module-labintegration/Dockerfile

# # Run the maven build in a container and copy the .omod file out
# docker run --name labintegration-build-tmp \
#   -v "$(pwd)/projects/openmrs-module-labintegration:/build" \
#   -w /build \
#   labintegration-build:local \
#   mvn clean package

# # Check if the build was successful
# if [ $? -ne 0 ]; then
#   echo "Build failed. Exiting."
#   exit 1
# fi

# # Copy the .omod file from the container to the desired location

# docker cp labintegration-build-tmp:/build/omod/target/*.omod packages/emr-isanteplus/config/custom_modules/

# # Clean up the container
# docker rm labintegration-build-tmp

## App

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

# ##
# # Cert Maintenance
# ##
# # Load Env vars from json file environmentVariables field
# filepath="./packages/reverse-proxy-nginx/package-metadata.json"

# envs=$(jq -r '.environmentVariables | to_entries | .[] | "\(.key)=\(.value)"' $filepath)

# # Export each environment variable
# while IFS= read -r line; do
#   export "$line"
# done <<< "$envs"

# # Build the Docker image
# docker build -t cert-maintenance:local ./projects/cert-maintenance

##
# Build the Platform to contain the above custom builds
##
./build-image.sh

echo "You can run the the Platform commands: E.g: ./instant-linux package init -p dev"



# Build and copy omod for labintegration module


