#!/bin/bash

set -e
set -o pipefail

bold=$(tput bold)
normal=$(tput sgr0)

printf "$bold%s$normal\n" "Please type root password and press enter"
read -rs password

export password=$password

printf "%s\n" "Running unit tests…"

expect ./tests/bip39.exp
expect ./tests/electrum.exp
expect ./tests/default.exp
expect ./tests/shamir.exp
expect ./tests/shamir2of3.exp
