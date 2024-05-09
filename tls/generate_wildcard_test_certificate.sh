#!/bin/bash

set -e

DOMAIN_NAME="*.test"
PRIVATE_KEY_FILENAME="traefik_wildcard.key"
CERTIFICATE_FILENAME="traefik_wildcard.crt"


openssl req -x509 \
                 -nodes \
                 -days 356 \
                 -newkey rsa:2048 \
                 -subj "/CN=$DOMAIN_NAME/C=NL/L=Amsterdam" \
                 -keyout ./keys/$PRIVATE_KEY_FILENAME \
                 -out ./certificates/$CERTIFICATE_FILENAME

echo "Generated new certificate for $DOMAIN_NAME"
