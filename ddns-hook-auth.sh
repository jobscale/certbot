#!/usr/bin/env bash
set -eu

dig-all() {
  echo
  echo "wait for DNS 5 minutes"
  for i in {10..1}
  do
    echo -n "$i .. "
    sleep 30
  done
  echo
  for domain in $(echo $CERTBOT_ALL_DOMAINS | sed -e 's/,/\n/g' | sort | uniq)
  do
    dig _acme-challenge.${domain} txt | grep -A 2 'ANSWER SECTION' | grep -w 'TXT'
  done
}

{
  echo "[CERTBOT - AUTH] (${CERTBOT_REMAINING_CHALLENGES})"
  sleep 1.1
  env | grep CERTBOT
  SUB=$(echo "${CERTBOT_DOMAIN}" | sed -e 's/\.jsx\.jp$//')
  DOMAIN=_acme-challenge.${SUB} TOKEN=$(date +%s) \
  TYPE=TXT R_DATA="${CERTBOT_VALIDATION}" \
  ENV=dev node app
  echo
  [[ "$CERTBOT_REMAINING_CHALLENGES" == "0" ]] && dig-all
  echo
}
