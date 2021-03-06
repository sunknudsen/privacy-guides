#! /bin/bash

set -e

positional=()
while [[ $# -gt 0 ]]; do
  argument="$1"
  case $argument in
    -h|--help)
    printf "%s\n" \
    "Usage: qr-clone.sh [options]" \
    "" \
    "Options:" \
    "  -h, --help  display help for command"
    exit 0
    ;;
    *)
    positional+=("$1")
    shift
    ;;
  esac
done

set -- "${positional[@]}"

tput reset

printf "%s\n" "Restoring…"
. qr-restore.sh

if [ -n "$secret" ]; then
  printf "%s\n" "Backing up…"
  . qr-backup.sh
fi
