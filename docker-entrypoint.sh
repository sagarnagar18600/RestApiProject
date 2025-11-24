#!/bin/sh
set -eu

# Flask CLI needs callable without parentheses
export FLASK_APP="app:create_app"

if [ -z "${DATABASE_URL:-}" ]; then
  echo "ERROR: DATABASE_URL is not set"
  exit 1
fi

echo "==> Running DB migrations"
flask db upgrade

echo "==> Starting app"
exec "$@"
