#! /bin/bash

iterations=3

positional=()
while [[ $# -gt 0 ]]; do
  argument="$1"
  case $argument in
    -h|--help)
    printf "%s\n" \
    "Usage: secure-erase.sh [options]" \
    "" \
    "Options:" \
    "  --iterations   overwrite n times (defauls to 3)" \
    "  --zero         overwrite with zeros to hide secure erase" \
    "  -h, --help     display help for command"
    exit 0
    ;;
    --iterations)
    iterations=$2
    shift
    shift
    ;;
    --zero)
    zero=true
    shift
    ;;
    *)
    positional+=("$1")
    shift
    ;;
  esac
done

set -- "${positional[@]}"

red=$(tput setaf 1)
normal=$(tput sgr0)

dev="/dev/sda1"

tput reset

waitForUsbThumbDrive () {
  if [ ! -e $dev ]; then
    printf "Insert USB flash drive and press enter"
    read -r confirmation
    waitForUsbThumbDrive
  fi
}

waitForUsbThumbDrive

printf "$red%s$normal\n" "Secure erase USB flash drive? (y or n)? "

read -r answer
if [ "$answer" = "y" ]; then
  array=($(seq 1 1 $iterations))
  for iteration in ${array[@]}; do
    printf "%s\n" "Erasing… (iteration $iteration of $iterations)"
    sudo dd bs=1M if=/dev/urandom of=$dev
  done
  if [ "$zero" = true ]; then
    printf "%s\n" "Writing zeros…"
    sudo dd bs=1M if=/dev/zero of=$dev
  fi
else
  exit 0
fi

printf "%s\n" "Done"
