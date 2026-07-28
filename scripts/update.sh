#!/bin/bash

set -e

CERT=/data/certs/certificates-new.tgz
CREDS=/root/.keys/scm-pan-chainguard.json

cd /opt/pan-chainguard

source venv/bin/activate

echo "[$(date)] Download latest certificates"

curl -s -L \
https://raw.githubusercontent.com/PaloAltoNetworks/pan-chainguard-content/main/latest-certs/certificates-new.tgz \
-o ${CERT}

echo "[$(date)] Update Root CA"

./bin/bashguard.py \
-C ${CREDS} \
--snippet pan-chainguard-root-CAs \
--update \
--certs ${CERT} \
-T root

echo "[$(date)] Update Intermediate CA"

./bin/bashguard.py \
-C ${CREDS} \
--snippet pan-chainguard-intermediate-CAs \
--update \
--certs ${CERT} \
-T intermediate

echo "[$(date)] Request OAuth token"

TOKEN=$(python3 - << 'PY'
import json
import requests

with open("/root/.keys/scm-pan-chainguard.json") as f:
    c=json.load(f)

r=requests.post(
    "https://auth.apps.paloaltonetworks.com/oauth2/access_token",
    data={
        "grant_type":"client_credentials",
        "client_id":c["client_id"],
        "client_secret":c["client_secret"]
    }
)

r.raise_for_status()
print(r.json()["access_token"])
PY
)

echo "[$(date)] Push Candidate Config"

curl -s -X POST \
"https://api.sase.paloaltonetworks.com/sse/config/v1/config-versions/candidate:push" \
-H "Authorization: Bearer ${TOKEN}" \
-H "Content-Type: application/json" \
-d '{
  "description":"pan-chainguard automated certificate update",
  "folders":[
    "Mobile Users",
    "Mobile Users Explicit Proxy",
    "Service Connections"
  ]
}'

echo
echo "[$(date)] Completed"
