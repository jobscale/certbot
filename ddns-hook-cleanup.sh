#!/usr/bin/env bash
set -eu

{
  echo -e '\n\n[CERTBOT - CLEANUP]\n\n'
  env | grep CERTBOT
  echo
}
