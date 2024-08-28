#!/bin/sh
set -eo pipefail

if [[ "${MOBYCRON_ENABLED}" == "true" || "${MOBYCRON_ENABLED}" == "1" ]]; then
    mobycron -f /configs/config.json &
fi

if [ "$1" = 'nginx' ]; then
    exec /docker-entrypoint.sh "$@"
fi

exec "$@"