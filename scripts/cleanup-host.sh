#!/bin/bash

rm -rf ./${CERTBOT_TOKEN}
az storage blob delete \
   --account-name b1e3gr2kv \
   -c acme \
   -n .well-known/acme-challenge/${CERTBOT_TOKEN} \
   --only-show-errors 2>&1 > /dev/null
