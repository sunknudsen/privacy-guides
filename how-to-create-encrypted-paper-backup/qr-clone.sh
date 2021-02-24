#! /bin/bash

set -e

printf "%s\n" "Restoring…"
. qr-restore.sh

if [ -n "$secret" ]; then
  printf "%s\n" "Backing up…"
  . qr-backup.sh
fi