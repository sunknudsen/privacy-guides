#! /bin/bash

set -e

share_threshold=3

positional=()
while [[ $# -gt 0 ]]; do
  argument="$1"
  case $argument in
    -h|--help)
    printf "%s\n" \
    "Usage: qr-restore.sh [options]" \
    "" \
    "Options:" \
    "  --shamir-secret-sharing    combine secret using Shamir Secret Sharing" \
    "  --share-threshold          shares required to access secret (defaults to 3)" \
    "  --word-list                split secret into word list" \
    "  -h, --help                 display help for command"
    exit 0
    ;;
    --shamir-secret-sharing)
    shamir_secret_sharing=true
    shift
    ;;
    --share-threshold)
    share_threshold=$2
    shift
    shift
    ;;
    --word-list)
    word_list=true
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
red=$(tput setaf 1)
normal=$(tput sgr0)

tput reset

scan_qr_code () {
  local -n data=$1

  printf "%s\n" "Scanning QR code…"
  
  data=$(zbarcam --nodisplay --oneshot --quiet --set disable --set qrcode.enable | sed 's/QR-Code://')

  data_hash=$(echo -n "$data" | openssl dgst -sha512 | sed 's/^.* //')
  data_short_hash=$(echo -n "$data_hash" | head -c 8)

  printf "%s\n" "$data"
  printf "%s: $bold%s$normal\n" "SHA512 hash" "$data_hash"
  printf "%s: $bold%s$normal\n" "SHA512 short hash" "$data_short_hash"
}

if [ "$shamir_secret_sharing" = true ]; then
  for share_number in $(seq 1 $share_threshold); do
    printf "$bold%s$normal" "Prepare share $share_number or $share_threshold and press enter"
    read -r confirmation
    scan_qr_code share
    shares="$share\n$shares"
  done
  encrypted_secret="$(echo -e "$shares" | secret-share-combine)"
else
  scan_qr_code encrypted_secret
fi

printf "$bold$red%s$normal\n" "Show secret? (y or n)? "

read -r answer
if [ "$answer" = "y" ]; then
  if [[ "$encrypted_secret" =~ "-----BEGIN PGP MESSAGE-----" ]]; then
    secret=$(echo -e "$encrypted_secret" | gpg --decrypt)
  else
    secret=$encrypted_secret
  fi

  if [ "$word_list" = true ]; then
    printf "%s\n" "Secret:"
    array=($secret)
    last_index=$(echo "${#array[@]} - 1" | bc)
    for index in ${!array[@]}; do
      position=$(($index + 1))
      printf "%d. $bold%s$normal" "$position" "${array[$index]}"
      if [ $index -lt $last_index ]; then
        printf " "
      fi
    done
    printf "\n"
  else
    printf "%s\n" "Secret:"
    echo "$bold$secret$normal"
  fi
fi

printf "%s\n" "Done"
