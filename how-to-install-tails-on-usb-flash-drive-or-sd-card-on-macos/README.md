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
- Computer running macOS Big Sur or Monterey

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command

## Guide

### Step 1: install [Homebrew](https://brew.sh/)

```console
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

$ uname -m | grep arm64 && echo 'export PATH=$PATH:/opt/homebrew/bin' >> ~/.zshrc && source ~/.zshrc
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
100 1341k  100 1341k    0     0  1451k      0 --:--:-- --:--:-- --:--:-- 1450k
gpg: key 0xDBB802B258ACD84F: 2170 signatures not checked due to missing keys
gpg: key 0xDBB802B258ACD84F: public key "Tails developers (offline long-term identity key) <tails@boum.org>" imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg: key 0xA3A31BAD5A2A5B10: no user ID for key signature packet of class 10
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   3  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 3u
```

imported: 1

👍

### Step 5: download [Tails](https://tails.boum.org/) release

Go to https://tails.boum.org/install/download/index.en.html and download latest release and associated PGP signature (found under “or download the OpenPGP signature”) to `~/Downloads` folder.

### Step 6: verify Tails release (learn how [here](../how-to-verify-pgp-digital-signatures-using-gnupg-on-macos))

Replace `4.25` with [latest release](https://tails.boum.org/install/download/index.en.html) semver.

```console
$ gpg --verify ~/Downloads/tails-amd64-4.25.img.sig
gpg: assuming signed data in '/Users/sunknudsen/Downloads/tails-amd64-4.25.img'
gpg: Signature made Mon  6 Dec 11:19:38 2021 EST
gpg:                using RSA key 05469FB85EAD6589B43D41D3D21DAD38AF281C0B
gpg: Good signature from "Tails developers (offline long-term identity key) <tails@boum.org>" [unknown]
gpg:                 aka "Tails developers <tails@boum.org>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: A490 D0F4 D311 A415 3E2B  B7CA DBB8 02B2 58AC D84F
     Subkey fingerprint: 0546 9FB8 5EAD 6589 B43D  41D3 D21D AD38 AF28 1C0B
```

Good signature

👍

### Step 7: copy Tails to USB flash drive or SD card

> WARNING: DO NOT RUN THE FOLLOWING COMMANDS AS-IS.

Run `diskutil list` to find disk ID of USB flash drive or SD card to overwrite with Tails (`disk4` in the following example).

Replace `diskn` and `rdiskn` with disk ID of USB flash drive or SD card (`disk4` and `rdisk4` in the following example) and `tails-amd64-4.25.img` with current image.

```console
$ diskutil list
/dev/disk0 (internal):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                         500.3 GB   disk0
   1:             Apple_APFS_ISC                         524.3 MB   disk0s1
   2:                 Apple_APFS Container disk3         494.4 GB   disk0s2
   3:        Apple_APFS_Recovery                         5.4 GB     disk0s3

/dev/disk3 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +494.4 GB   disk3
                                 Physical Store disk0s2
   1:                APFS Volume Macintosh HD            15.3 GB    disk3s1
   2:              APFS Snapshot com.apple.os.update-... 15.3 GB    disk3s1s1
   3:                APFS Volume Preboot                 328.4 MB   disk3s2
   4:                APFS Volume Recovery                815.1 MB   disk3s3
   5:                APFS Volume Data                    439.3 GB   disk3s5
   6:                APFS Volume VM                      7.5 GB     disk3s6

/dev/disk4 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *32.1 GB    disk4
   1:               Windows_NTFS Untitled                32.1 GB    disk4s1

$ sudo diskutil unmount /dev/diskn
disk4 was already unmounted or it has a partitioning scheme so use "diskutil unmountDisk" instead

$ sudo diskutil unmountDisk /dev/diskn (if previous step fails)
Unmount of all volumes on disk4 was successful

$ sudo dd bs=1m if=$HOME/Downloads/tails-amd64-4.25.img of=/dev/rdiskn
1139+0 records in
1139+0 records out
1194328064 bytes transferred in 49.463690 secs (24145551 bytes/sec)

$ sudo diskutil unmountDisk /dev/diskn
Unmount of all volumes on disk4 was successful
```

👍
