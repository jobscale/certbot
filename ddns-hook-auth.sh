#!/usr/bin/env bash
set -eu

dig-all() {
  CHALLENGE="$1"
  echo
  echo "wait for DNS n seconds - ${CERTBOT_VALIDATION}"
  for i in {30..1}
  do
    sleep 4
    echo "  $i / 30"
    echo "dig ${CHALLENGE} txt +short"
    dig ${CHALLENGE} txt +short
    ANSWER_SECTION=$(dig ${CHALLENGE} txt +short)
    ANSWER=$(
      echo "${ANSWER_SECTION}" | grep -- "${CERTBOT_VALIDATION}" | wc -l
    )
    [[ "${ANSWER}" == "1" ]] && break
  done
  echo
  echo -e "dig result: \n${ANSWER_SECTION}"
  echo -e "short result: \n$(dig ${CHALLENGE} txt +short)"
  if [[ "${ANSWER}" != "1" ]]; then
    echo -e "\e[31m DNS record not found. \e[0m"
    exit 1
  fi
}

auth() {
  echo
  env | grep CERTBOT
  echo
  echo -e "\e[32m $(TZ=Asia/Tokyo date -Iseconds) === [CERTBOT - AUTH] ${CERTBOT_DOMAIN} (${CERTBOT_REMAINING_CHALLENGES}) ===\e[0m"
  echo
  CHALLENGE=_acme-challenge.${CERTBOT_DOMAIN}
  SUB=$(echo "${CHALLENGE}" | sed -e 's/jsx\.jp$//' | sed -e 's/\.$//')
  DOMAIN=${SUB} TOKEN=$(date +%s) \
  TYPE=TXT R_DATA="${CERTBOT_VALIDATION}" \
  MULTIPLE=allow ENV=dev node app/index.js
  echo
  dig-all "${CHALLENGE}"
  echo
  if [[ "${CERTBOT_REMAINING_CHALLENGES}" == "0" ]]; then
    echo -e "\e[33m Challenge is set. Wait for a while... \e[0m"
    for domain in $(echo $CERTBOT_ALL_DOMAINS | sed -e 's/,/\n/g' | sort | uniq)
    do
      dig _acme-challenge.${domain} txt +short
    done
    echo -e "\e[33m All challenges are set. Wait for a while... \e[0m"
    sleep 120
  fi
  echo
}

{
  auth
}
