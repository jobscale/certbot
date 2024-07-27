#!/usr/bin/env bash
set -eu

dig-all() {
  echo
  for i in {30..1}
  do
    echo -n "$i .. "
    sleep 10
  done
  for domain in $(echo $CERTBOT_ALL_DOMAINS | sed -e 's/,/\n/g' | sort | uniq)
  do
    dig _acme-challenge.${domain} txt | grep -A 2 'ANSWER SECTION' | grep -w 'TXT'
  done
}

{
  echo "[CERTBOT - AUTH] (${CERTBOT_REMAINING_CHALLENGES})"
  sleep 1.1
  env | grep CERTBOT
  CERTBOT_AUTH=true CERTBOT_DOMAIN=_acme-challenge.${CERTBOT_DOMAIN} \
  ENV=dev node app
  echo
  [[ "$CERTBOT_REMAINING_CHALLENGES" == "0" ]] && dig-all
  echo
}
