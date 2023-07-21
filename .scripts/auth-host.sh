#!/bin/bash

echo ${CERTBOT_VALIDATION} > ./${CERTBOT_TOKEN}
az storage blob upload \
   --account-name b1e3gr2kv \
   -c acme \
   -n .well-known/acme-challenge/${CERTBOT_TOKEN} \
   -f ${CERTBOT_TOKEN} \
   --only-show-errors 2>&1 > /dev/null
