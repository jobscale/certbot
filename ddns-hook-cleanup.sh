#!/usr/bin/env bash
set -eu

time {
  echo " $(TZ=Asia/Tokyo date -Iseconds) === [CERTBOT - CLEANUP] ${CERTBOT_DOMAIN} (${CERTBOT_REMAINING_CHALLENGES}) ==="
  echo
  env | grep CERTBOT
  echo
  CHALLENGE=_acme-challenge.${CERTBOT_DOMAIN}
  SUB=$(echo "${CHALLENGE}" | sed -e 's/jsx\.jp$//' | sed -e 's/\.$//')
  DOMAIN=${SUB} TOKEN=$(date +%s) \
  TYPE=TXT R_DATA="${CERTBOT_VALIDATION}" \
  DELETE_ONLY=allow ENV=dev node app/index.js
  echo
} | tee -a CHALLENGE.${CERTBOT_DOMAIN}.log
