#! /bin/bash

set -e

bold=$(tput bold)
red=$(tput setaf 1)
normal=$(tput sgr0)

dev="/dev/sda1"
tmp="/home/pi/tmp"
usb="/home/pi/usb"

waitForUsb () {
  if [ ! -e $dev ]; then
    printf "Insert USB thumb drive and press enter"
    read -r confirmation
    waitForUsb
  fi
}

waitForUsb

sudo mkdir -p $tmp
if ! mount | grep $tmp > /dev/null; then
  sudo mount -t tmpfs -o size=100m tmp $tmp
fi

sudo mkdir -p $usb
if ! mount | grep $usb > /dev/null; then
  sudo mount $dev $usb -o uid=pi,gid=pi
fi

if [ -z $secret ]; then
  printf "%s\n" "Type secret and press enter"
  read -r secret
fi

encrypted_secret=$(echo -n "$secret" | gpg --s2k-mode 3 --s2k-count 65011712 --s2k-digest-algo sha512 --cipher-algo AES256 --symmetric --armor)
gpg-connect-agent reloadagent /bye > /dev/null 2>&1

encrypted_secret_hash=$(echo -n "$encrypted_secret" | openssl dgst -sha512 | sed 's/^.* //')
encrypted_secret_short_hash=$(echo -n "$encrypted_secret_hash" | head -c 8)

printf "%s\n" "$encrypted_secret"
printf "SHA512 hash: $bold%s$normal\n" "$encrypted_secret_hash"
printf "SHA512 short hash: $bold%s$normal\n" "$encrypted_secret_short_hash"

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

sudo umount $tmp

sudo umount $usb

printf "%s\n" "Done"
