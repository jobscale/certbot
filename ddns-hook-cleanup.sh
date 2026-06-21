#!/usr/bin/env bash
set -eu

cleanup() {
  sleep 2
  echo
  env | grep CERTBOT
  echo
  echo -e "\e[32m $(TZ=Asia/Tokyo date -Iseconds) === [CERTBOT - CLEANUP] ${CERTBOT_DOMAIN} (${CERTBOT_REMAINING_CHALLENGES}) ===\e[0m"
  echo
  CHALLENGE=_acme-challenge.${CERTBOT_DOMAIN}
  echo -e "before delete short: \n$(dig ${CHALLENGE} txt +short)"
  echo
  SUB=$(echo "${CHALLENGE}" | sed -e 's/jsx\.jp$//' | sed -e 's/\.$//')
  DOMAIN=${SUB} TOKEN=$(date +%s) \
  TYPE=TXT R_DATA="${CERTBOT_VALIDATION}" \
  DELETE=allow ENV=dev node app/index.js
  echo
}

{
  cleanup
}
