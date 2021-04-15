#! /bin/bash

set -e

number_of_shares=5
share_threshold=3

positional=()
while [[ $# -gt 0 ]]; do
  argument="$1"
  case $argument in
    -h|--help)
    printf "%s\n" \
    "Usage: qr-backup.sh [options]" \
    "" \
    "Options:" \
    "  --create-bip39-mnemonic      create BIP39 mnemonic" \
    "  --create-electrum-mnemonic   create Electrum mnemonic" \
    "  --validate-bip39-mnemonic    validate if secret is valid BIP39 mnemonic" \
    "  --shamir-secret-sharing      split secret using Shamir Secret Sharing" \
    "  --number-of-shares           number of shares (defaults to 5)" \
    "  --share-threshold            shares required to access secret (defaults to 3)" \
    "  --no-encryption              disable symmetric encryption (shamir-only)" \
    "  --no-qr                      disable “Show SHA512 hash as QR code”" \
    "  --label <label>              print label after short hash" \
    "  -h, --help                   display help for command"
    exit 0
    ;;
    --create-bip39-mnemonic)
    create_bip39_mnemonic=true
    shift
    ;;
    --create-electrum-mnemonic)
    create_electrum_mnemonic=true
    shift
    ;;
    --validate-bip39-mnemonic)
    validate_bip39_mnemonic=true
    shift
    ;;
    --shamir-secret-sharing)
    shamir_secret_sharing=true
    shift
    ;;
    --number-of-shares)
    number_of_shares=$2
    shift
    shift
    ;;
    --share-threshold)
    share_threshold=$2
    shift
    shift
    ;;
    --no-encryption)
    no_encryption=true
    shift
    ;;
    --no-qr)
    no_qr=true
    shift
    ;;
    --label)
    label=$2
    shift
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

wait_for_usb_flash_drive () {
  if [ ! -e $dev ]; then
    printf "$bold%s$normal" "Insert USB flash drive and press enter"
    read -r confirmation
    wait_for_usb_flash_drive
  fi
}

wait_for_usb_flash_drive

printf "$bold%s$normal\n" "Format USB flash drive? (y or n)? "

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

if [ -z "$duplicate" ] && [ "$create_bip39_mnemonic" = true ]; then
  printf "%s\n" "Creating BIP39 mnemonic…"
  secret=$(python3 $basedir/create-bip39-mnemonic.py)
  echo $secret
  sleep 1
fi

if [ -z "$duplicate" ] && [ "$create_electrum_mnemonic" = true ]; then
  printf "%s\n" "Creating Electrum mnemonic…"
  secret=$(electrum make_seed --nbits 264 --offline)
  echo $secret
  sleep 1
fi

if [ -z "$duplicate" ] && [ -z "$secret" ]; then
  tput sc
  printf "$bold%s$normal\n" "Type secret and press enter, then ctrl-d"
  readarray -t secret_array
  secret=$(printf "%s\n" "${secret_array[@]}")
  tput rc
  tput ed
  printf "$bold%s$normal\n" "Type secret and press enter, then ctrl-d (again)"
  readarray -t secret_confirmation_array
  secret_confirmation=$(printf "%s\n" "${secret_confirmation_array[@]}")
  if [ ! "$secret" = "$secret_confirmation" ]; then
    printf "$red%s$normal\n" "Secrets do not match"
    exit 1
  fi
fi

if [ -z "$duplicate" ] && [ "$validate_bip39_mnemonic" = true ]; then
  printf "%s\n" "Validating if secret is valid BIP39 mnemonic…"
  if ! echo -n "$secret" | python3 $basedir/validate-bip39-mnemonic.py; then
    printf "$bold$red%s$normal\n" "Invalid BIP39 mnemonic"
    exit 1
  fi
fi

if [ "$duplicate" = true ] && [ -n "$encrypted_secret" ]; then
  printf "%s\n" "Duplicating encrypted secret…"
else
  if [ -z "$shamir_secret_sharing" ] || ([ "$shamir_secret_sharing" = true ] && [ -z "$no_encryption" ]); then
    encrypted_secret=$(echo -n "$secret" | gpg --s2k-mode 3 --s2k-count 65011712 --s2k-digest-algo sha512 --cipher-algo AES256 --symmetric --armor)
    gpg-connect-agent reloadagent /bye > /dev/null 2>&1
  fi
fi

if [ "$shamir_secret_sharing" = true ]; then
  if [ -n "$encrypted_secret" ]; then
    secret="$encrypted_secret"
  fi

  share_number=1
  for share in $(echo -n "$secret" | secret-share-split -n $number_of_shares -t $share_threshold); do
    printf "$bold%s$normal\n" "Generating share $share_number or $number_of_shares…"

    encrypted_secret="$share"
    encrypted_secret_hash=$(echo -n "$encrypted_secret" | openssl dgst -sha512 | sed 's/^.* //')
    encrypted_secret_short_hash=$(echo -n "$encrypted_secret_hash" | head -c 8)

    printf "%s\n" "$encrypted_secret"
    printf "%s: $bold%s$normal\n" "SHA512 hash" "$encrypted_secret_hash"
    printf "%s: $bold%s$normal\n" "SHA512 short hash" "$encrypted_secret_short_hash"

    echo -n "$encrypted_secret" | qr --error-correction L > "$tmp/secret.png"

    font_size=$(echo "$(convert "$tmp/secret.png" -format "%h" info:) / 8" | bc)
    text_offset=$(echo "$font_size * 1.5" | bc)

    if [ -z "$label" ]; then
      text="$encrypted_secret_short_hash $share_number"
    else
      text="$encrypted_secret_short_hash $label-$share_number"
    fi

    convert "$tmp/secret.png" -gravity center -scale 200% -extent 125% -scale 125% -gravity south -font /usr/share/fonts/truetype/noto/NotoMono-Regular.ttf -pointsize $font_size -fill black -draw "text 0,$text_offset '$text'" "$usb/$encrypted_secret_short_hash.jpg"

    if [ -z "$no_qr" ]; then
      printf "$bold%s$normal\n" "Show SHA512 hash as QR code? (y or n)? "

      read -r answer
      if [ "$answer" = "y" ]; then
        printf "$bold%s$normal\n" "Press q to quit"
        sleep 1
        echo -n "$encrypted_secret_hash" | qr --error-correction L > "$tmp/secret-hash.png"
        sudo fim --autozoom --quiet --vt 1 "$tmp/secret-hash.png"
      fi
    fi

    share_number=$((share_number+1))
  done
else
  encrypted_secret_hash=$(echo -n "$encrypted_secret" | openssl dgst -sha512 | sed 's/^.* //')
  encrypted_secret_short_hash=$(echo -n "$encrypted_secret_hash" | head -c 8)

  printf "%s\n" "$encrypted_secret"
  printf "%s: $bold%s$normal\n" "SHA512 hash" "$encrypted_secret_hash"
  printf "%s: $bold%s$normal\n" "SHA512 short hash" "$encrypted_secret_short_hash"

  echo -n "$encrypted_secret" | qr --error-correction L > "$tmp/secret.png"

  font_size=$(echo "$(convert "$tmp/secret.png" -format "%h" info:) / 8" | bc)
  text_offset=$(echo "$font_size * 1.5" | bc)

  if [ -z "$label" ]; then
    text="$encrypted_secret_short_hash"
  else
    text="$encrypted_secret_short_hash $label"
  fi

  convert "$tmp/secret.png" -gravity center -scale 200% -extent 125% -scale 125% -gravity south -font /usr/share/fonts/truetype/noto/NotoMono-Regular.ttf -pointsize $font_size -fill black -draw "text 0,$text_offset '$text'" "$usb/$encrypted_secret_short_hash.jpg"

  if [ -z "$no_qr" ]; then
    printf "$bold%s$normal\n" "Show SHA512 hash as QR code? (y or n)? "

    read -r answer
    if [ "$answer" = "y" ]; then
      printf "$bold%s$normal\n" "Press q to quit"
      sleep 1
      echo -n "$encrypted_secret_hash" | qr --error-correction L > "$tmp/secret-hash.png"
      sudo fim --autozoom --quiet --vt 1 "$tmp/secret-hash.png"
    fi
  fi
fi

sudo umount $usb

printf "%s\n" "Done"
