# PAN Chainguard for SCM

Automated Root CA and Intermediate CA synchronization to Strata Cloud Manager (SCM).

## Features

- Daily certificate update
- Root CA sync
- Intermediate CA sync
- Prisma Access Config Push
- Dockerized deployment
- UGREEN NAS compatible

## Run

docker compose up -d

## Manual Update

docker exec pan-chainguard /scripts/update.sh

