#! /bin/bash

set -e

tput reset

printf "%s\n" "Restoring…"
. qr-restore.sh

if [ -n "$secret" ]; then
  printf "%s\n" "Backing up…"
  . qr-backup.sh
fi
