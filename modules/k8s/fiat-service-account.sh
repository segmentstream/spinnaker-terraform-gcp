#!/bin/bash

apk add --no-cache curl

FRONT50=http://spin-front50.spinnaker:8080

curl -X POST \
  -H "Content-type: application/json" \
  -d '{ "name": "${name}", "memberOf": ${roles} }' \
  $FRONT50/serviceAccounts

curl $FRONT50/serviceAccounts

FIAT=http://spin-fiat.spinnaker:7003

curl -X POST $FIAT/roles/sync

sleep 10

exit 0