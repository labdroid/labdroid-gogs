#!/bin/sh

set -x

cd /opt/gogs

if [ -z "$VAULT_MINIO_READ_ACCESS_TOKEN" ]; then
    echo ERROR: VAULT_MINIO_READ_ACCESS_TOKEN environment variable missing.  Create this secret in OpenShift.
    exit 1
fi

SECRETS=`curl -H "X-Vault-Token: $VAULT_MINIO_READ_ACCESS_TOKEN" -X GET http://vault:8200/v1/secret/minio`

MINIO_ACCESS_KEY=`echo $SECRETS | jq -r .data.MINIO_ACCESS_KEY`
MINIO_SECRET_KEY=`echo $SECRETS | jq -r .data.MINIO_SECRET_KEY`

rm -f gogs-backup*.zip

USER=gogs ./gogs backup

FILE=`ls gogs-backup*.zip`

content_type="application/octet-stream"
DATE=`date -R`
_signature="PUT\n\n${content_type}\n${DATE}\n/backup/${FILE}"
signature=`echo -en ${_signature} | openssl sha1 -hmac ${MINIO_SECRET_KEY} -binary | base64`

curl -v -X PUT -T "${FILE}" \
          -H "Host: minio" \
          -H "Date: ${DATE}" \
          -H "Content-Type: application/octet-stream" \
          -H "Authorization: AWS ${MINIO_ACCESS_KEY}:${signature}" \
          http://minio:9000/backup/${FILE}



