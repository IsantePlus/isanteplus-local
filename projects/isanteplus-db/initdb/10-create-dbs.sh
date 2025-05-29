#!/bin/bash
set -e

if [ -z "$OPENMRS_DB_COUNT" ]; then
  # set default
  OPENMRS_DB_COUNT=1
fi

if [ -z "$INITIAL_SQL_FILE" ]; then

  echo "INITIAL_SQL_FILE not set. Please provide the path to the SQL dump file."
  exit 1
fi

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "MYSQL_ROOT_PASSWORD is not set."
  exit 1
fi

echo "OPENMRS_DB_COUNT: $OPENMRS_DB_COUNT"
for i in $(seq 1 "$OPENMRS_DB_COUNT"); do


  if [ "$i" -eq 1 ]; then
    db="openmrs"
  else
    db="openmrs$i"
  fi
  
  echo "username: $OMRS_CONFIG_CONNECTION_USERNAME_1"

  # Check if user variable is set
  if [ -z "$OMRS_CONFIG_CONNECTION_USERNAME_1" ]; then
    user="$OMRS_CONFIG_CONNECTION_USERNAME_1"
  else
    # raise an error if the user variable is not set
    if [ -z "$OMRS_CONFIG_CONNECTION_USERNAME_$i" ]; then
      echo "OMRS_CONFIG_CONNECTION_USERNAME_$i is not set. Please provide a username for the database."
    fi
    user="openmrs"
  fi

  echo "password: $OMRS_CONFIG_CONNECTION_PASSWORD_1"

  if [ -z "$OMRS_CONFIG_CONNECTION_PASSWORD_1" ]; then
    password="$OMRS_CONFIG_CONNECTION_PASSWORD_1"
  else
    # raise an error if the password variable is not set

    if [ -z "$OMRS_CONFIG_CONNECTION_PASSWORD_$i" ]; then
      echo "OMRS_CONFIG_CONNECTION_PASSWORD_$i is not set. Please provide a password for the database."
    fi
    password="change_for_prod!"
  fi

  echo "Creating database: $db"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$db\`;"

  echo "Creating user '$user' with password '$password'"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$user'@'%' IDENTIFIED BY '$password';"

  echo "Granting privileges to '$user' on $db"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL ON \`$db\`.* TO '$user'@'%'; FLUSH PRIVILEGES;"

  echo "Loading initial dump into $db from $INITIAL_SQL_FILE"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$db" < "$INITIAL_SQL_FILE"
done
