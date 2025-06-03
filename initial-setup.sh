#!/usr/bin/env bash
#
# init_config.sh
#

# This script will:
#   1. Prompt for secrets (always asks user) and store them securely in the Linux keychain.
#   2. Prompt for non-sensitive env vars (always asks user) with hardcoded defaults in the script.
#   3. Copy ".env.local" to ".env" and append environment variables from user input.
#
# Usage: ./init_config.sh
#

##
# Update / Install Required Packages
##
sudo apt-get update
sudo apt-get install git secret-tool

##
# Install / Update Docker
##
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Create keychain secrets for:
# - MySQL user password
# - MySQL root password
# - OpenHIM root passwor
  


# ---- Helper Functions ----

# Prompt for secret with an optional label for storing in keychain.
# No default is used here (or you can define one if you like).
ask_secret() {
  local var_name="$1"
  local prompt_msg="$2"
  local label="$3"         # For keychain (secret-tool)
  local service="$4"       # For keychain (secret-tool)
  local user="$5"          # For keychain (secret-tool)

  echo
  echo "=== $prompt_msg ==="
  # '-s' makes read silent (no echo back). Remove -s if you want to show typed characters.
  read -s -p "Enter $prompt_msg: " secret_val
  echo

  # Store in keychain if user entered something
  if [ -n "$secret_val" ]; then
    echo "Storing $prompt_msg in keychain..."
    secret-tool store --label="$label" service="$service" user="$user" <<< "$secret_val"
    echo "$prompt_msg stored in keychain."
  else
    echo "No input for $prompt_msg. Nothing was stored."
  fi

  # Export to a shell variable if needed for immediate usage (optional)
  eval "$var_name=\"$secret_val\""
}

# Prompt for an env var with a hardcoded default.
ask_env_with_default() {
  local var_name="$1"
  local prompt_msg="$2"
  local default_val="$3"

  echo
  echo "=== $prompt_msg ==="
  read -p "Enter value (default: $default_val): " user_input
  # If user presses Enter (no input), use the default
  if [ -z "$user_input" ]; then
    user_input="$default_val"
  fi

  # Export the final chosen value into a shell variable
  eval "$var_name=\"$user_input\""
}

# ---- 1) Collect Secrets Securely ----

echo "=== Step 1: Gather secrets for storage in the Linux keychain ==="
echo "You will be prompted for each secret (no defaults). Press Enter to skip a secret if not needed."

# Example secret #1: OpenHIM admin password
ask_secret OPENHIM_ADMIN_PASSWORD \
  "OpenHIM Admin Password" \
  "OpenHIM Admin Password" \
  "openhim" \
  "admin"

# Example secret #2: MySQL root password
ask_secret MYSQL_ROOT_PASSWORD \
  "MySQL Root Password" \
  "MySQL Root Password" \
  "mysql" \
  "root"

# Add more secrets if needed...

# ---- 2) Gather Non-Sensitive ENV Variables (Hardcoded Defaults) ----

echo
echo "=== Step 2: Configure non-sensitive environment variables ==="
echo "You will be prompted for each variable with a default. Press Enter to accept the default."

ask_env_with_default OPENHIM_CORE_MEDIATOR_HOSTNAME \
  "OPENHIM_CORE_MEDIATOR_HOSTNAME" \
  "openhimcomms.isanteplus.uwdigi.org"

ask_env_with_default OPENHIM_MEDIATOR_API_PORT \
  "OPENHIM_MEDIATOR_API_PORT" \
  "8899"

ask_env_with_default OPENHIM_CORE_MEDIATOR_HOSTNAME_2 \
  "OPENHIM_CORE_MEDIATOR_HOSTNAME_2 (2nd var, if needed)" \
  "isanteplus.uwdigi.org"

ask_env_with_default OPENHIM_MONGO_URL \
  "OPENHIM_MONGO_URL" \
  "mongodb://mongo-1:27017/openhim"

ask_env_with_default OPENHIM_MONGO_ATNAURL \
  "OPENHIM_MONGO_ATNAURL" \
  "mongodb://mongo-1:27017/openhim"

ask_env_with_default OPENHIM_CONSOLE_BASE_URL \
  "OPENHIM_CONSOLE_BASE_URL" \
  "https://openhimconsole.isanteplus.uwdigi.org"

ask_env_with_default OPENHIM_CONSOLE_SHOW_LOGIN \
  "OPENHIM_CONSOLE_SHOW_LOGIN" \
  "true"

ask_env_with_default MYSQL_USE_LOCAL \
  "MYSQL_USE_LOCAL" \
  "false"

ask_env_with_default OMRS_CONFIG_CONNECTION_USERNAME_1 \
  "OMRS_CONFIG_CONNECTION_USERNAME_1" \
  "openmrs"

ask_env_with_default OMRS_CONFIG_CONNECTION_URL_1 \
  "OMRS_CONFIG_CONNECTION_URL_1" \
  "jdbc:mysql://mysql:3306/openmrs?autoReconnect=true"

ask_env_with_default OMRS_CONFIG_CONNECTION_USERNAME_2 \
  "OMRS_CONFIG_CONNECTION_USERNAME_2" \
  "openmrs2"

ask_env_with_default OMRS_CONFIG_CONNECTION_URL_2 \
  "OMRS_CONFIG_CONNECTION_URL_2" \
  "jdbc:mysql://mysql:3306/openmrs2?autoReconnect=true"

ask_env_with_default DOMAIN_NAME \
  "DOMAIN_NAME" \
  "isanteplus.uwdigi.org"

ask_env_with_default SUBDOMAINS \
  "SUBDOMAINS" \
  "pestel.isanteplus.uwdigi.org,charess.isanteplus.uwdigi.org,openhim.isanteplus.uwdigi.org,openhimcomms.isanteplus.uwdigi.org,openhimcore.isanteplus.uwdigi.org,legacy.isanteplus.uwdigi.org"

ask_env_with_default STAGING \
  "STAGING" \
  "false"

ask_env_with_default INSECURE \
  "INSECURE" \
  "false"

# ---- 3) Generate the .env File ----

echo
echo "=== Step 3: Create .env from .env.local and append environment variables ==="

if [ ! -f .env.local ]; then
  echo "ERROR: .env.local does not exist in the current directory!"
  exit 1
fi

cp .env.local .env

# Append the user-provided environment variables
{
  echo "OPENHIM_CORE_MEDIATOR_HOSTNAME=$OPENHIM_CORE_MEDIATOR_HOSTNAME"
  echo "OPENHIM_MEDIATOR_API_PORT=$OPENHIM_MEDIATOR_API_PORT"
  echo "OPENHIM_CORE_MEDIATOR_HOSTNAME_2=$OPENHIM_CORE_MEDIATOR_HOSTNAME_2"
  echo "OPENHIM_MONGO_URL=$OPENHIM_MONGO_URL"
  echo "OPENHIM_MONGO_ATNAURL=$OPENHIM_MONGO_ATNAURL"
  echo "OPENHIM_CONSOLE_BASE_URL=$OPENHIM_CONSOLE_BASE_URL"
  echo "OPENHIM_CONSOLE_SHOW_LOGIN=$OPENHIM_CONSOLE_SHOW_LOGIN"
  echo "MYSQL_USE_LOCAL=$MYSQL_USE_LOCAL"
  echo "OMRS_CONFIG_CONNECTION_USERNAME_1=$OMRS_CONFIG_CONNECTION_USERNAME_1"
  echo "OMRS_CONFIG_CONNECTION_URL_1=$OMRS_CONFIG_CONNECTION_URL_1"
  echo "OMRS_CONFIG_CONNECTION_USERNAME_2=$OMRS_CONFIG_CONNECTION_USERNAME_2"
  echo "OMRS_CONFIG_CONNECTION_URL_2=$OMRS_CONFIG_CONNECTION_URL_2"
  echo "DOMAIN_NAME=$DOMAIN_NAME"
  echo "SUBDOMAINS=$SUBDOMAINS"
  echo "STAGING=$STAGING"
  echo "INSECURE=$INSECURE"
} >> .env

echo
echo "=== Initialization Complete! ==="
echo "Secrets have been stored in your keychain (if you provided any)."
echo "A new .env file has been created with your chosen values."
