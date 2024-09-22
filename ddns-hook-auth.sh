#!/usr/bin/env bash
set -eu

dig-all() {
  CHALLENGE="$1"
  echo
  echo "wait for DNS n seconds"
  sleep 10
  for i in {10..1}
  do
    echo -n "$i .. "
    ANSWER=$(dig _acme-challenge.${domain} txt | grep -A 2 'ANSWER SECTION' | grep -w 'TXT' | grep "${CERTBOT_VALIDATION}" | wc -l)
    [[ "${ANSWER}" == "1" ]] && break
    sleep 10
  done
  echo
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
  dig-all "${CHALLENGE}"
  echo
} | tee -a CHALLENGE.${CERTBOT_DOMAIN}.log
