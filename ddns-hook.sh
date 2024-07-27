#!/usr/bin/env bash
set -eu

{
  env | grep CERTBOT
  cd /root
  ENV=dev node app
}
