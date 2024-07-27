#!/usr/bin/env bash
set -eu

{
  sleep ${CERTBOT_REMAINING_CHALLENGES}.9
  echo '[CERTBOT - CLEANUP]'
  env | grep CERTBOT
  # CERTBOT_CLEANUP=true CERTBOT_DOMAIN=_acme-challenge.${CERTBOT_DOMAIN} \
  # ENV=dev node app
  dig _acme-challenge.${CERTBOT_DOMAIN} txt
  echo
}
