#!/bin/bash -x

certbot certonly \
        --non-interactive \
        --agree-tos \
        --manual \
        --config-dir=./certbot/config \
        --logs-dir=./certbot/logs \
        --work-dir=./certbot/work \
        --email jlabat@simplonformations.onmicrosoft.com \
        --preferred-challenges=http \
        --manual-auth-hook ./scripts/auth-host.sh \
        --manual-cleanup-hook ./scripts/cleanup-host.sh \
        -d b1e3-gr2-wiki-js.westeurope.cloudapp.azure.com > /dev/null

openssl pkcs12 -export \
        -out ./cert.pfx \
        -inkey ./certbot/config/live/b1e3-gr2-wiki-js.westeurope.cloudapp.azure.com/privkey.pem \
        -in ./certbot/config/live/b1e3-gr2-wiki-js.westeurope.cloudapp.azure.com/fullchain.pem \
        -passout pass:"${SSL_PASSWD}" > /dev/null

az keyvault certificate import --vault-name b1e3gr2vault2 \
        -f ./cert.pfx \
        -n wiki-js \
        --password "${SSL_PASSWD}" > /dev/null
