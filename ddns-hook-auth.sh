#!/usr/bin/env bash
set -eu

dig-all() {
  CHALLENGE="$1"
  echo
  echo -n "wait for DNS n seconds - "
  for i in {30..1}
  do
    sleep 4
    echo -n "$i .. "
    ANSWER_SECTION=$(dig ${CHALLENGE} txt +short)
    ANSWER=$(
      echo "${ANSWER_SECTION}" | grep -- "${CERTBOT_VALIDATION}" | wc -l
    )
    [[ "${ANSWER}" == "1" ]] && break
  done
  echo
  echo -e "dig result: \n${ANSWER_SECTION}"
  echo "short result: $(dig ${CHALLENGE} txt +short)"
}

auth() {
  echo -e "\e[33m $(TZ=Asia/Tokyo date -Iseconds) === [CERTBOT - AUTH] ${CERTBOT_DOMAIN} (${CERTBOT_REMAINING_CHALLENGES}) ===\e[0m"
  echo
  env | grep CERTBOT
  echo
  CHALLENGE=_acme-challenge.${CERTBOT_DOMAIN}
  SUB=$(echo "${CHALLENGE}" | sed -e 's/jsx\.jp$//' | sed -e 's/\.$//')
  DOMAIN=${SUB} TOKEN=$(date +%s) \
  TYPE=TXT R_DATA="${CERTBOT_VALIDATION}" \
  MULTIPLE=allow ENV=dev node app/index.js
  echo
  dig-all "${CHALLENGE}"
  echo
  [[ "${CERTBOT_REMAINING_CHALLENGES}" == "0" ]] && {
    for domain in $(echo $CERTBOT_ALL_DOMAINS | sed -e 's/,/\n/g' | sort | uniq)
    do
      dig _acme-challenge.${domain} txt +short
    done
    sleep 120
  }
  echo
}

{
  auth | tee -a CHALLENGE.${CERTBOT_DOMAIN}.log
}
