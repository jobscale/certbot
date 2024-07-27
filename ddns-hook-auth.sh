#!/usr/bin/env bash
set -eu

{
  echo '[CERTBOT - AUTH]'
  env | grep CERTBOT
  CERTBOT_AUTH=true CERTBOT_DOMAIN=_acme-challenge.${CERTBOT_DOMAIN} \
  ENV=dev node app
  dig _acme-challenge.${CERTBOT_DOMAIN} txt
  echo
}
