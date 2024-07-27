#!/usr/bin/env bash
set -eu

{
  env | grep CERTBOT
  CERTBOT_AUTH=true CERTBOT_VALIDATION=_acme-challenge.${CERTBOT_VALIDATION} \
  ENV=dev node app
}
