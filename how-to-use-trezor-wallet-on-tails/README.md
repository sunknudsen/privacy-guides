<!--
Title: How to use Trezor Wallet on Tails
Description: Learn how to use Trezor Wallet on Tails.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2021-05-09T12:10:53.922Z
Listed: true
-->

# How to use Trezor Wallet on Tails

> Heads-up: guide is not persistent meaning steps have to be completed each time one needs to use Trezor Wallet on Tails.

## Requirements

- [Tails USB flash drive or SD card](../how-to-install-tails-on-usb-flash-drive-or-sd-card-on-macos)

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command

## Setup guide

### Step 1: boot to Tails and set admin password (required to run commands using `sudo`)

> Heads-up: if keyboard layout of computer isn’t “English (US)”, set “Keyboard Layout”.

Click “+” under ”Additional Settings”, then “Administration Password”, set password, click “Add” and finally “Start Tails”.

### Step 2: establish network connection using ethernet cable or Wi-Fi and wait for Tor to be ready

Connected to Tor successfully

👍

### Step 3: set Trezor Bridge release year environment variable

Replace `2020` with [latest release](https://github.com/trezor/trezord-go/blob/master/CHANGELOG.md) year.

```shell
TREZOR_BRIDGE_RELEASE_YEAR=2020
```

### Step 4: import “SatoshiLabs Signing Key” PGP public key (used to verify downloads below)

```console
$ torsocks curl https://trezor.io/security/satoshilabs-${TREZOR_BRIDGE_RELEASE_YEAR}-signing-key.asc | gpg --import
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  2415  100  2415    0     0   1500      0  0:00:01  0:00:01 --:--:--  1499
gpg: key 0x26A3A56662F0E7E2: 1 signature not checked due to a missing key
gpg: key 0x26A3A56662F0E7E2: public key "SatoshiLabs 2020 Signing Key" imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg: no ultimately trusted keys found
```

imported: 1

👍

### Step 5: set [Trezor Bridge](https://wiki.trezor.io/Trezor_Bridge) release semver environment variable

Replace `2.0.30` with [latest release](https://github.com/trezor/trezord-go/blob/master/CHANGELOG.md) semver.

```shell
TREZOR_BRIDGE_RELEASE_SEMVER=2.0.30
```

### Step 6: download Trezor Bridge release

```shell
torsocks curl -O https://wallet.trezor.io/data/bridge/${TREZOR_BRIDGE_RELEASE_SEMVER}/trezor-bridge_${TREZOR_BRIDGE_RELEASE_SEMVER}_amd64.deb
```

### Step 7: verify Trezor Bridge release (learn how [here](../how-to-verify-pgp-digital-signatures-using-gnupg-on-macos))

```console
$ gpg --verify trezor-bridge_${TREZOR_BRIDGE_RELEASE_SEMVER}_amd64.deb
gpg: Signature made Sat 07 Nov 2020 11:43:05 AM UTC
gpg:                using RSA key 54067D8BBF00554181B5AB8F26A3A56662F0E7E2
gpg: Good signature from "SatoshiLabs 2020 Signing Key" [expired]
gpg: Note: This key has expired!
Primary key fingerprint: 5406 7D8B BF00 5541 81B5  AB8F 26A3 A566 62F0 E7E2
```

Good signature

👍

### Step 8: install Trezor Bridge

```console
$ sudo dpkg -i trezor-bridge_${TREZOR_BRIDGE_RELEASE_SEMVER}_amd64.deb
[sudo] password for amnesia:
Selecting previously unselected package trezor-bridge.
(Reading database ... 130446 files and directories currently installed.)
Preparing to unpack trezor-bridge_2.0.30_amd64.deb ...
Unpacking trezor-bridge (2.0.30) ...
Setting up trezor-bridge (2.0.30) ...
Created symlink /etc/systemd/system/multi-user.target.wants/trezord.service → /usr/lib/systemd/system/trezord.service.
```

### Step 9: configure firewall

```console
$ sudo iptables -I OUTPUT 3 -o lo -s 127.0.0.1/32 -d 127.0.0.1/32 -p tcp --dport 21325 --syn -m owner --uid-owner amnesia -m conntrack --ctstate NEW -j ACCEPT
[sudo] password for amnesia:
```

### Step 10: configure Tor Browser

Click “Applications”, then “Tor Browser”, go to `about:config`, click “Accept the Risk and Continue”, and set following properties.

`network.proxy.no_proxies_on` 👉 `127.0.0.1:21325`

`network.http.referer.hideOnionSource` 👉 `false`

### Step 11: open [Trezor Wallet](https://wallet.trezor.io/)

👍
