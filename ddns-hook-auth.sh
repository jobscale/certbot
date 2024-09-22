#!/usr/bin/env bash
set -eu

dig-all() {
  echo
  echo "wait for DNS 120 seconds"
  for i in {10..1}
  do
    echo -n "$i .. "
    sleep 12
  done
  echo
  for domain in $(echo $CERTBOT_ALL_DOMAINS | sed -e 's/,/\n/g' | sort | uniq)
  do
    dig _acme-challenge.${domain} txt | grep -A 2 'ANSWER SECTION' | grep -w 'TXT'
  done
}

{
  echo " === [CERTBOT - AUTH] (${CERTBOT_REMAINING_CHALLENGES}) ==="
  env | grep CERTBOT
  [[ "$CERTBOT_REMAINING_CHALLENGES" == "0" ]] && exit
  CHALLENGE=_acme-challenge.${CERTBOT_DOMAIN}
  SUB=$(echo "${CHALLENGE}" | sed -e 's/jsx\.jp$//' | sed -e 's/\.$//')
  DOMAIN=${SUB} TOKEN=$(date +%s) \
  TYPE=TXT R_DATA="${CERTBOT_VALIDATION}" \
  ENV=dev node app
  echo
  dig-all
  echo
} | tee -a CHALLENGE.${CERTBOT_DOMAIN}.log
