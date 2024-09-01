#!/bin/sh
set -eo pipefail

if [ "${LEGO_MODE}" == "staging" ]; then
    lego --accept-tos \
        --server=https://acme-staging-v02.api.letsencrypt.org/directory \
        --domains="$1" \
        --email="$2" \
        --http \
        --http.webroot /var/www/acme \
        run
else
    lego --accept-tos \
        --domains="$1" \
        --email="$2" \
        --http \
        --http.webroot /var/www/acme \
        run
fi