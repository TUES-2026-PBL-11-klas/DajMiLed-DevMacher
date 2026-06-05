#!/bin/sh
# Export each Vault-injected secret file as an uppercase environment variable
if [ -d /vault/secrets ]; then
  for f in /vault/secrets/*; do
    [ -f "$f" ] || continue
    KEY=$(basename "$f" | tr '[:lower:]' '[:upper:]')
    VALUE=$(cat "$f")
    export "$KEY=$VALUE"
  done
fi
exec java -jar /app/app.jar
