#!/usr/bin/env bash
set -eu

{
  sleep ${CERTBOT_REMAINING_CHALLENGES}.9
  echo '[CERTBOT - AUTH]'
  env | grep CERTBOT
  CERTBOT_AUTH=true CERTBOT_DOMAIN=_acme-challenge.${CERTBOT_DOMAIN} \
  ENV=dev node app
  sleep 120
  dig _acme-challenge.${CERTBOT_DOMAIN} txt
  echo
}
