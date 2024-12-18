#!/bin/bash
set -euo pipefail

# Environment Variables Expected:
# DOMAIN_NAME (e.g., "example.com")
# RENEWAL_EMAIL (e.g., "admin@example.com")
# STACK (e.g., "reverse-proxy")
# SERVICE_NAMES (e.g., "reverse-proxy-nginx")
#
# Optional:
# SUBDOMAINS (e.g., "www.example.com,api.example.com") 
# STAGING ("true" or "false") - If true, uses Let's Encrypt staging servers
#
# The script expects:
# - Certificates stored in /instant/certificates/fullchain1.pem and privkey1.pem
# - instant volume mounted at /instant
# - Docker socket mounted at /var/run/docker.sock to run Docker commands

CERT_DIR="/instant/certificates"
FULLCHAIN="${CERT_DIR}/fullchain1.pem"
PRIVKEY="${CERT_DIR}/privkey1.pem"

# Construct domain arguments for certbot
DOMAIN_ARGS=("-d" "${DOMAIN_NAME}")
if [[ -n "${SUBDOMAINS:-}" ]]; then
    DOMAIN_ARGS=("-d" "${DOMAIN_NAME},${SUBDOMAINS}")
fi

function are_certs_valid() {
    # Check if cert and key files exist
    if [[ ! -f "$FULLCHAIN" || ! -f "$PRIVKEY" ]]; then
        return 1
    fi

    # Check if certificate is valid for at least another 30 days (2592000 seconds)
    if openssl x509 -checkend 2592000 -noout -in "$FULLCHAIN"; then
        return 0
    else
        return 1
    fi
}

function update_secrets() {
    local timestamp
    timestamp="$(date "+%Y%m%d%H%M%S")"

    # Attempt to detect and remove existing secrets
    existing_fullchain=$(docker service inspect ${STACK}_${SERVICE_NAMES} --format "{{(index .Spec.TaskTemplate.ContainerSpec.Secrets 0).SecretName}}" || true)
    existing_privkey=$(docker service inspect ${STACK}_${SERVICE_NAMES} --format "{{(index .Spec.TaskTemplate.ContainerSpec.Secrets 1).SecretName}}" || true)

    if [[ -n "$existing_fullchain" ]]; then
        docker secret rm "$existing_fullchain" || true
    fi
    if [[ -n "$existing_privkey" ]]; then
        docker secret rm "$existing_privkey" || true
    fi

    docker secret create --label name=nginx ${timestamp}-fullchain.pem "$FULLCHAIN"
    docker secret create --label name=nginx ${timestamp}-privkey.pem "$PRIVKEY"

    docker service update \
        --secret-rm "$existing_fullchain" \
        --secret-rm "$existing_privkey" \
        --secret-add source=${timestamp}-fullchain.pem,target=/run/secrets/fullchain.pem \
        --secret-add source=${timestamp}-privkey.pem,target=/run/secrets/privkey.pem \
        ${STACK}_${SERVICE_NAMES}
}

function renew_certificates() {
    local staging_args=""
    if [[ "${STAGING:-false}" == "true" ]]; then
        staging_args="--staging"
    fi

    # Run certbot to obtain/renew certificates
    # We'll use certbot's default paths (/etc/letsencrypt) inside the container.
    # After obtaining the certs, we copy them into /instant/certificates.
    certbot certonly --non-interactive --agree-tos \
        --standalone \
        ${staging_args} \
        -m "${RENEWAL_EMAIL}" \
        "${DOMA
