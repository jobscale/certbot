#!/usr/bin/env bash
set -eu

{
  env | grep CERTBOT
  CERTBOT_AUTH=true CERTBOT_DOMAIN=_acme-challenge.${CERTBOT_DOMAIN} \
  ENV=dev node app
}
