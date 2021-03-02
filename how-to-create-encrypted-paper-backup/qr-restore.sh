#! /bin/bash

set -e

positional=()
while [[ $# -gt 0 ]]; do
  argument="$1"
  case $argument in
    -h|--help)
    printf "%s\n" \
    "Usage: qr-restore.sh [options]" \
    "" \
    "Options:" \
    "  --word-list    split secret into word list" \
    "  -h, --help     display help for command"
    exit 0
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

printf "%s\n" "Scan QR code…"

data=""

while read line; do
  if echo -n $line | grep -Eq "^QR-Code:"; then
    line=$(echo -n $line | sed 's/QR-Code://')
  fi
  data="$data$line"
  if [ "$line" = "-----END PGP MESSAGE-----" ]; then
    killall zbarcam --signal SIGINT
  else
    data="$data\n"
  fi
done < <(zbarcam --nodisplay --quiet)

encrypted_secret=$(echo -e $data)

encrypted_secret_hash=$(echo -n "$encrypted_secret" | openssl dgst -sha512 | sed 's/^.* //')
encrypted_secret_short_hash=$(echo -n "$encrypted_secret_hash" | head -c 8)

printf "%s\n" "$encrypted_secret"
printf "%s: $bold%s$normal\n" "SHA512 hash" "$encrypted_secret_hash"
printf "%s: $bold%s$normal\n" "SHA512 short hash" "$encrypted_secret_short_hash"

printf "$bold$red%s$normal\n" "Show secret? (y or n)? "

read -r answer
if [ "$answer" = "y" ]; then
  secret=$(echo -e "$encrypted_secret" | gpg --decrypt)
  gpg-connect-agent reloadagent /bye > /dev/null 2>&1
  if [ "$word_list" = true ]; then
    printf "%s" "Secret: "
    array=($secret)
    for i in ${!array[@]}; do
      position=$(($i + 1))
      printf "%d. $bold%s$normal " "$position" "${array[$i]}"
    done
    printf "\n"
  else
    printf "Secret: $bold%s$normal\n" "$secret"
  fi
fi

printf "%s\n" "Done"
