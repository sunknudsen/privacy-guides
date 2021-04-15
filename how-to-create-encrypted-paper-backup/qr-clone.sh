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

printf "%s\n" "Type qr-restore.sh options and press enter (see “qr-restore.sh --help”)"
read -r qr_restore_options

. qr-restore.sh $qr_restore_options

if [ -n "$secret" ]; then
  printf "%s\n" "Backing up…"

  printf "%s\n" "Type qr-backup.sh options and press enter (see “qr-backup.sh --help”)"
  read -r qr_backup_options

  . qr-backup.sh $qr_backup_options
fi
