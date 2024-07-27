#!/usr/bin/env bash
set -eu

dig-all() {
  sleep 120
  for domain in $(echo $CERTBOT_ALL_DOMAINS | sed -e 's/,/ /g' )
  do
    dig _acme-challenge.${domain} txt | grep -A 2 'ANSWER SECTION' | grep -w 'TXT'
  done
}

{
  TIME=$(( 24 - ${CERTBOT_REMAINING_CHALLENGES} )).9
  echo "[CERTBOT - AUTH] TIME = $TIME"
  sleep $TIME
  env | grep CERTBOT
  CERTBOT_AUTH=true CERTBOT_DOMAIN=_acme-challenge.${CERTBOT_DOMAIN} \
  ENV=dev node app
  echo
  [[ "$CERTBOT_REMAINING_CHALLENGES" == "0" ]] && dig-all
  echo
}
