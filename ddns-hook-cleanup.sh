#!/usr/bin/env bash
set -eu

{
  echo -e "\n\n[CERTBOT - CLEANUP] (${CERTBOT_REMAINING_CHALLENGES})\n\n"
  env | grep CERTBOT
  echo
}
