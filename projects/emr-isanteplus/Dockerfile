FROM tomcat:7-jdk8 AS run

## Take some initial steps to improve overall security, size, and functionality of the container
## This includes updating packages and removing all of the default Tomcat webapps

RUN apt-get update && \
    apt-get install -y zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /usr/local/tomcat/webapps/*

RUN sed -i '/Connector port="8080"/a URIEncoding="UTF-8" relaxedPathChars="[]|" relaxedQueryChars="[]|{}^&#x5c;&#x60;&quot;&lt;&gt;"' /usr/local/tomcat/conf/server.xml

# All environment variables that are available to configure on this container are listed here
# for clarity.  These list the variables supported, and the default values if not overridden

# These environment variables are appended to configure the Tomcat JAVA_OPTS
ENV OMRS_JAVA_MEMORY_OPTS="-Xmx2048m -Xms1024m -XX:NewSize=128m"
ENV OMRS_JAVA_SERVER_OPTS="-Dfile.encoding=UTF-8 -server -Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Djava.awt.headlesslib=true"

# These environment variables are used to create the openmrs-server.properties file, which controls how OpenMRS initializes
ENV OMRS_CONFIG_ADD_DEMO_DATA="false"
ENV OMRS_CONFIG_ADMIN_USER_PASSWORD="Admin123"
ENV OMRS_CONFIG_AUTO_UPDATE_DATABASE="true"
# valid values are mysql and postgres
ENV OMRS_CONFIG_CONNECTION_TYPE="mysql"
ENV OMRS_CONFIG_CONNECTION_USERNAME="mysqluser"
ENV OMRS_CONFIG_CONNECTION_PASSWORD="mysqlpw"
ENV OMRS_CONFIG_CONNECTION_SERVER="localhost"
ENV OMRS_CONFIG_CONNECTION_NAME="openmrs"
ENV OMRS_CONFIG_CREATE_DATABASE_USER="false"
ENV OMRS_CONFIG_CREATE_TABLES="false"
ENV OMRS_CONFIG_HAS_CURRENT_OPENMRS_DATABASE="true"
ENV OMRS_CONFIG_INSTALL_METHOD="auto"
ENV OMRS_CONFIG_MODULE_WEB_ADMIN="true"

# These environment variables are meant to enable developer settings
ENV OMRS_DEV_DEBUG_PORT="1044"

# Additional environment variables as needed.  This should match the name of the distribution supplied OpenMRS war file
ENV OMRS_WEBAPP_NAME="openmrs"

COPY ./distribution/openmrs_modules /openmrs/distribution/openmrs_modules
COPY ./distribution/openmrs_webapps /openmrs/distribution/openmrs_webapps

# Set up volumes.
# /openmrs/data represents the data persisted inside the container to the filesystem for OpenMRS
VOLUME ["/openmrs/data"]
VOLUME ["/openmrs/distribution"]
VOLUME ["/custom_modules"]

# Copy in the start-up scripts
COPY ./resources/wait-for-it.sh /usr/local/tomcat/wait-for-it.sh
COPY ./resources/startup.sh /usr/local/tomcat/startup.sh
RUN chmod +x /usr/local/tomcat/wait-for-it.sh
RUN chmod +x /usr/local/tomcat/startup.sh

# Add Dockerfile and commit info for documentation
ADD ./Dockerfile /openmrs/docker

EXPOSE 8080

COPY ./entrypoint-wrapper.sh /entrypoint-wrapper.sh

RUN chmod +x /entrypoint-wrapper.sh

ENTRYPOINT ls /custom_modules && /entrypoint-wrapper.sh
