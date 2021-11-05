<!--
Title: How to install Tails on USB flash drive or SD card on macOS
Description: Learn how to install Tails on USB flash drive or SD card on macOS.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>, 7aqdxe6f <https://github.com/7aqdxe6f>
Reviewers:
Publication date: 2021-05-05T14:49:08.692Z
Listed: true
-->

# How to install Tails on USB flash drive or SD card on macOS

[![Why Tails is not only for hacktivists and whistleblowers and how to get started](why-tails-is-not-only-for-hacktivists-and-whistleblowers-and-how-to-get-started.png)](https://www.youtube.com/watch?v=kZ4NHz-gjLo "Why Tails is not only for hacktivists and whistleblowers and how to get started")

## Requirements

- USB flash drive or SD card (faster is better)
- Computer running macOS Catalina or Big Sur

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command

## Guide

### Step 1: install [Homebrew](https://brew.sh/)

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
uname -m | grep arm64 && echo 'export PATH=$PATH:/opt/homebrew/bin' >> ~/.zshrc && source ~/.zshrc
```

### Step 2: disable Homebrew analytics

```shell
brew analytics off
```

### Step 3: install [GnuPG](https://gnupg.org/)

```shell
brew install gnupg
```

### Step 4: import “Tails developers” PGP public key

```console
$ curl https://tails.boum.org/tails-signing.key | gpg --import
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 1334k  100 1334k    0     0  92536      0  0:00:14  0:00:14 --:--:--  212k
gpg: key 0xDBB802B258ACD84F: 2170 signatures not checked due to missing keys
gpg: key 0xDBB802B258ACD84F: public key "Tails developers (offline long-term identity key) <tails@boum.org>" imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg: key 0x4E2C6E8793298290: no user ID for key signature packet of class 10
gpg: key 0x4E2C6E8793298290: no user ID for key signature packet of class 12
gpg: key 0x4E2C6E8793298290: no user ID for key signature packet of class 12
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   3  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 3u
```

imported: 1

👍

### Step 5: download [Tails](https://tails.boum.org/) release

Go to https://tails.boum.org/install/download/index.en.html and download latest release and associated PGP signature (found under “or download the OpenPGP signature”) to `~/Downloads` folder.

### Step 6: verify Tails release (learn how [here](../how-to-verify-pgp-digital-signatures-using-gnupg-on-macos))

> Heads-up: replace `4.19` with [latest release](https://tails.boum.org/install/download/index.en.html) semver.

```console
$ gpg --verify ~/Downloads/tails-amd64-4.19.img.sig
gpg: assuming signed data in '/Users/sunknudsen/Downloads/tails-amd64-4.18.img'
gpg: Signature made Mon 19 Apr 11:30:01 2021 EDT
gpg:                using EDDSA key CD4D4351AFA6933F574A9AFB90B2B4BD7AED235F
gpg: Good signature from "Tails developers (offline long-term identity key) <tails@boum.org>" [unknown]
gpg:                 aka "Tails developers <tails@boum.org>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: A490 D0F4 D311 A415 3E2B  B7CA DBB8 02B2 58AC D84F
     Subkey fingerprint: CD4D 4351 AFA6 933F 574A  9AFB 90B2 B4BD 7AED 235F
```

Good signature

👍

### Step 7: copy Tails to USB flash drive or SD card

> WARNING: DO NOT RUN THE FOLLOWING COMMANDS AS-IS.

Run `diskutil list` to find disk ID of USB flash drive or SD card to overwrite with Tails (`disk2` in the following example).

Replace `diskn` and `rdiskn` with disk ID of USB flash drive or SD card (`disk2` and `rdisk2` in the following example) and `tails-amd64-4.18.img` with current image.

```console
$ diskutil list
/dev/disk0 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *500.3 GB   disk0
   1:                        EFI EFI                     209.7 MB   disk0s1
   2:                 Apple_APFS Container disk1         500.1 GB   disk0s2

/dev/disk1 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +500.1 GB   disk1
                                 Physical Store disk0s2
   1:                APFS Volume Macintosh HD - Data     340.9 GB   disk1s1
   2:                APFS Volume Preboot                 85.9 MB    disk1s2
   3:                APFS Volume Recovery                529.0 MB   disk1s3
   4:                APFS Volume VM                      3.2 GB     disk1s4
   5:                APFS Volume Macintosh HD            11.3 GB    disk1s5

/dev/disk2 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *15.9 GB    disk2
   1:             Windows_FAT_32 boot                    268.4 MB   disk2s1
   2:                      Linux                         15.7 GB    disk2s2

$ sudo diskutil unmount /dev/diskn
disk2 was already unmounted or it has a partitioning scheme so use "diskutil unmountDisk" instead

$ sudo diskutil unmountDisk /dev/diskn (if previous step fails)
Unmount of all volumes on disk2 was successful

$ sudo dd bs=1m if=$HOME/Downloads/tails-amd64-4.18.img of=/dev/rdiskn
1131+0 records in
1131+0 records out
1185939456 bytes transferred in 44.708618 secs (26525970 bytes/sec)

$ sudo diskutil unmountDisk /dev/diskn
Unmount of all volumes on disk2 was successful
```

👍
