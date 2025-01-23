FROM alpine:3.18

# Install necessary packages:
# - bash: for scripting
# - openssl: to check certificate expiration
# - certbot: for renewing certificates
# - docker-cli: to run docker commands (assuming /var/run/docker.sock is mounted)
RUN apk add --no-cache bash openssl certbot docker-cli

# Create directories
RUN mkdir -p /var/log

# Copy the renewal script into the container
COPY renew-certs.sh /usr/local/bin/renew-certs.sh
RUN chmod +x /usr/local/bin/renew-certs.sh

# Set up a cron job to run at midnight every day
# Adjust timing as needed.
RUN echo "0 0 * * * /usr/local/bin/renew-certs.sh >> /var/log/cert-renew.log 2>&1" > /etc/crontabs/root

# The default command runs crond in the foreground
CMD ["crond", "-f", "-l", "2"]
