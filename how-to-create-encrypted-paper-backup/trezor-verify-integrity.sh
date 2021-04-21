#! /bin/bash

set -e
set -o pipefail

function cleanup()
{
  sudo kill 0
  exit 0
}

trap cleanup INT EXIT

positional=()
while [[ $# -gt 0 ]]; do
  argument="$1"
  case $argument in
    -h|--help)
    printf "%s\n" \
    "Usage: trezor-validate.sh [options]" \
    "" \
    "Options:" \
    "  --qr-restore-options   see \`qr-restore.sh --help\`" \
    "  -h, --help             display help for command"
    exit 0
    ;;
    --qr-restore-options)
    qr_restore_options=$2
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
normal=$(tput sgr0)

basedir=$(dirname "$0")

tput reset

printf "%s\n" "Spawning tmux panes…"

sleep 1

sudo bash -c "python3 $basedir/tmux-buttons.py &"

tmux new -d -s trezor-validate
tmux rename-window -t trezor-validate trezorctl
tmux send-keys -t trezor-validate "trezorctl recovery-device --words 24 --type scrambled --dry-run" Enter
tmux split-window -t trezor-validate
tmux rename-window -t trezor-validate qr-restore
tmux send-keys -t trezor-validate "qr-restore.sh $(echo $qr_restore_options | sed 's/--word-list *//') --word-list" Enter
tmux attach -t trezor-validate

tput reset

printf "$bold%s$normal\n" "Press ctrl+c to exit"

while :
do
  sleep 60
done
