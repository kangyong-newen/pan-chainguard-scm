# PAN Chainguard SCM Automation

Automated Root CA and Intermediate CA synchronization for Strata Cloud Manager (SCM) using Palo Alto Networks pan-chainguard.

## Features

- Automated Root CA updates
- Automated Intermediate CA updates
- SCM Custom Certificate synchronization
- Prisma Access Candidate Config Push
- Docker Compose deployment
- Scheduled daily updates

---

## Prerequisites

### SCM Service Account

Create a Service Account in:

```text
Common Services
└── Identity and Access
    └── Access Management
        └── Add Identity
            └── Service Account
```

Required information:

- TSG ID
- Client ID
- Client Secret

---

## SCM Snippet Creation

Create the following snippets in SCM:

```text
pan-chainguard-root-CAs
pan-chainguard-intermediate-CAs
```

---

## Credentials Configuration

A sample credentials file is provided:

```text
secrets/scm-pan-chainguard.json.example
```

Create a working copy:

```bash
cp secrets/scm-pan-chainguard.json.example \
   secrets/scm-pan-chainguard.json
```

Edit:

```json
{
    "tsg_id": "YOUR_TSG_ID",
    "client_id": "your-service-account@xxxxxxxxxx.iam.panserviceaccount.com",
    "client_secret": "YOUR_CLIENT_SECRET"
}
```

Example:

```json
{
    "tsg_id": "1946918741",
    "client_id": "service-account@1946918741.iam.panserviceaccount.com",
    "client_secret": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

> IMPORTANT  
> Never commit `scm-pan-chainguard.json` to Git.
>
> The file is ignored automatically through `.gitignore`.

---

## Deployment

Build and start the container:

```bash
docker compose build
docker compose up -d
```

Verify:

```bash
docker ps
```

Enter the container:

```bash
docker exec -it pan-chainguard bash
```

---

## Manual Update

Run manually:

```bash
docker exec pan-chainguard /scripts/update.sh
```

The script performs:

1. Download latest certificate bundle
2. Update Root CA certificates
3. Update Intermediate CA certificates
4. Push Prisma Access candidate configuration

---

## Logs

View update log:

```bash
tail -f update.log
```

---

## Automatic Scheduling

### Example Cron Job

```cron
0 2 * * * /usr/bin/docker exec pan-chainguard /scripts/update.sh >> /volume1/docker/pan-chainguard/update.log 2>&1
```

Runs every day at:

```text
02:00 AM
```

---

## Project Structure

```text
pan-chainguard/
├── Dockerfile
├── docker-compose.yaml
├── README.md
├── .gitignore
├── data/
│   └── certs/
├── scripts/
│   └── update.sh
├── secrets/
│   ├── scm-pan-chainguard.json.example
│   └── scm-pan-chainguard.json
└── update.log
```

---

## Security Notes

Never commit:

```text
secrets/scm-pan-chainguard.json
```

Never commit:

```text
Client Secret
OAuth Tokens
Certificate Archives
```

If a Client Secret is accidentally exposed, immediately:

1. Revoke the existing secret
2. Generate a new secret
3. Update `scm-pan-chainguard.json`

---

## Useful Commands

Check Root CA objects:

```bash
docker exec -it pan-chainguard bash

cd /opt/pan-chainguard
source venv/bin/activate

./bin/bashguard.py \
-C /root/.keys/scm-pan-chainguard.json \
--snippet pan-chainguard-root-CAs \
--show
```

Check Intermediate CA objects:

```bash
./bin/bashguard.py \
-C /root/.keys/scm-pan-chainguard.json \
--snippet pan-chainguard-intermediate-CAs \
--show
```

Run update manually:

```bash
docker exec pan-chainguard /scripts/update.sh
```
