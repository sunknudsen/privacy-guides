#! /bin/bash

set -e

positional=()
while [[ $# -gt 0 ]]; do
  argument="$1"
  case $argument in
    -h|--help)
    printf "%s\n" \
    "Usage: qr-backup.sh [options]" \
    "" \
    "Options:" \
    "  --bip39      test secret against BIP39 word list" \
    "  -h, --help   display help for command"
    exit 0
    ;;
    --bip39)
    bip39=true
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

basedir=$(dirname "$0")

dev="/dev/sda1"
tmp="/tmp/pi"
usb="/tmp/usb"

tput reset

waitForUsbThumbDrive () {
  if [ ! -e $dev ]; then
    printf "Insert USB flash drive and press enter"
    read -r confirmation
    waitForUsbThumbDrive
  fi
}

waitForUsbThumbDrive

printf "%s\n" "Format USB flash drive? (y or n)? "

read -r answer
if [ "$answer" = "y" ]; then
  if mount | grep $usb > /dev/null; then
    sudo umount $dev
  fi
  sudo mkfs -t vfat $dev
fi

sudo mkdir -p $usb
if ! mount | grep $usb > /dev/null; then
  sudo mount $dev $usb -o uid=pi,gid=pi
fi

if [ -z "$secret" ]; then
  tput sc
  printf "%s\n" "Type secret and press enter"
  read -r secret
  tput rc
  tput ed
  printf "%s\n" "Type secret and press enter (again)"
  read -r secret_confirmation
  if [ ! "$secret" = "$secret_confirmation" ]; then
    printf "$red%s$normal\n" "Secrets do not match"
    exit 1
  fi
fi

function exists {
  bip39_words=($(cat "$basedir/bip39.txt"))
  for bip39_word in ${bip39_words[@]}; do
    if [ "$bip39_word" = "$1" ]; then
      return 0
    fi
  done
  return 1
}

if [ "$bip39" = true ]; then
  printf "%s\n" "Testing secret against BIP39 word list…"
  words=($secret)
  for word in ${words[@]}; do
    if ! exists $word; then
      printf "$red%s $bold%s$normal\n" "Invalid word" "$word"
      exit 1
    fi
  done
fi

encrypted_secret=$(echo -n "$secret" | gpg --s2k-mode 3 --s2k-count 65011712 --s2k-digest-algo sha512 --cipher-algo AES256 --symmetric --armor)
gpg-connect-agent reloadagent /bye > /dev/null 2>&1

encrypted_secret_hash=$(echo -n "$encrypted_secret" | openssl dgst -sha512 | sed 's/^.* //')
encrypted_secret_short_hash=$(echo -n "$encrypted_secret_hash" | head -c 8)

printf "%s\n" "$encrypted_secret"
printf "%s: $bold%s$normal\n" "SHA512 hash" "$encrypted_secret_hash"
printf "%s: $bold%s$normal\n" "SHA512 short hash" "$encrypted_secret_short_hash"

echo -n "$encrypted_secret" | qr --error-correction=H > "$tmp/secret.png"

font_size=$(echo "$(convert "$tmp/secret.png" -format "%h" info:) / 8" | bc)
text_offset=$(echo "$font_size * 1.5" | bc)

convert "$tmp/secret.png" -gravity center -scale 200% -extent 125% -scale 125% -gravity south -font /usr/share/fonts/truetype/noto/NotoMono-Regular.ttf -pointsize $font_size -fill black -draw "text 0,$text_offset '$encrypted_secret_short_hash'" "$usb/$encrypted_secret_short_hash.jpg"

printf "%s\n" "Show SHA512 hash as QR code? (y or n)? "

read -r answer
if [ "$answer" = "y" ]; then
  printf "%s\n" "Press q to quit"
  sleep 1
  echo -n "$encrypted_secret_hash" | qr --error-correction=L > "$tmp/secret-hash.png"
  sudo fim --autozoom --quiet --vt 1 "$tmp/secret-hash.png"
fi

sudo umount $usb

printf "%s\n" "Done"
