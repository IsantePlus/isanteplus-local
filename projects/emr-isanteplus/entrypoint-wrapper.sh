#!/bin/bash
# entrypoint-wrapper.sh

if [ -n "$OMRS_CONFIG_ADMIN_USER_PASSWORD_FILE" ] && [ -f "$OMRS_CONFIG_ADMIN_USER_PASSWORD_FILE" ]; then
    export OMRS_CONFIG_ADMIN_USER_PASSWORD="$(cat $OMRS_CONFIG_ADMIN_USER_PASSWORD_FILE)"
fi

if [ -n "$OMRS_CONFIG_CONNECTION_PASSWORD_FILE" ] && [ -f "$OMRS_CONFIG_CONNECTION_PASSWORD_FILE" ]; then
    export OMRS_CONFIG_CONNECTION_PASSWORD="$(cat $OMRS_CONFIG_CONNECTION_PASSWORD_FILE)"
fi

# Finally, hand off to the original script.  This runs Tomcat or OpenMRS
exec /usr/local/tomcat/startup.sh
