#!/usr/bin/env bash
set -eu

dig-all() {
  CHALLENGE="$1"
  echo
  echo -n "wait for DNS n seconds - "
  for i in {10..1}
  do
    sleep 10
    echo -n "$i .. "
    ANSWER=$(
      dig ${CHALLENGE} txt | grep -A 2 'ANSWER SECTION' | grep -w 'TXT' | grep "${CERTBOT_VALIDATION}" | wc -l
    )
    [[ "${ANSWER}" == "1" ]] && break
  done
  echo
}

time {
  echo " $(TZ=Asia/Tokyo date -Iseconds) === [CERTBOT - AUTH] ${CERTBOT_DOMAIN} (${CERTBOT_REMAINING_CHALLENGES}) ==="
  echo
  env | grep CERTBOT
  echo
  CHALLENGE=_acme-challenge.${CERTBOT_DOMAIN}
  SUB=$(echo "${CHALLENGE}" | sed -e 's/jsx\.jp$//' | sed -e 's/\.$//')
  DOMAIN=${SUB} TOKEN=$(date +%s) \
  TYPE=TXT R_DATA="${CERTBOT_VALIDATION}" \
  ENV=dev node app
  echo
  dig-all "${CHALLENGE}"
  echo
  [[ "${CERTBOT_REMAINING_CHALLENGES}" == "0" ]] && {
    for domain in $(echo $CERTBOT_ALL_DOMAINS | sed -e 's/,/\n/g' | sort | uniq)
    do
      dig _acme-challenge.${domain} txt | grep -A 2 'ANSWER SECTION' | grep -w 'TXT'
    done
    sleep 120
  }
  echo
} | tee -a CHALLENGE.${CERTBOT_DOMAIN}.log
