#!/usr/bin/env bash
set -eu

{
  pwd
  cd /root
  ENV=dev node app
}
