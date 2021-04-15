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
    "  --duplicate    duplicate content" \
    "  -h, --help     display help for command"
    exit 0
    ;;
    --duplicate)
    duplicate=true
    shift
    ;;
    *)
    positional+=("$1")
    shift
    ;;
  esac
done

set -- "${positional[@]}"

bold=$(tput bold)
normal=$(tput sgr0)

tput reset

printf "%s\n" "Restoring…"

if [ -z "$duplicate" ]; then
  printf "$bold%s$normal\n" "Type qr-restore.sh options and press enter (see “qr-restore.sh --help”)"
  read -r qr_restore_options
fi

. qr-restore.sh $qr_restore_options

if [ -n "$secret" ] || [ -n "$encrypted_secret" ]; then
  printf "%s\n" "Backing up…"

  printf "$bold%s$normal\n" "Type qr-backup.sh options and press enter (see “qr-backup.sh --help”)"
  read -r qr_backup_options

  . qr-backup.sh $qr_backup_options
fi
