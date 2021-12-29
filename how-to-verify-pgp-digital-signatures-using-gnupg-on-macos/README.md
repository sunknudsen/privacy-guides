<!--
Title: How to verify PGP digital signatures using GnuPG on macOS
Description: Learn how to verify PGP digital signatures using GnuPG on macOS.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2021-03-24T12:40:31.074Z
Listed: true
-->

# How to verify PGP digital signatures using GnuPG on macOS

[![How to verify PGP digital signatures using GnuPG on macOS](how-to-verify-pgp-digital-signatures-using-gnupg-on-macos.png)](https://www.youtube.com/watch?v=WnNfunEJdQY "How to verify PGP digital signatures using GnuPG on macOS")

## Requirements

- Computer running macOS Big Sur or Monterey

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command

## Setup guide

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

👍

---

## Usage guide

### Import signer’s PGP public key using key server…

Replace `0x8C9CA674C47CA060` with signer’s public key ID.

```console
$ gpg --keyserver hkps://keys.openpgp.org --recv-keys 0x8C9CA674C47CA060
gpg: key 8C9CA674C47CA060: public key "Sun Knudsen <hello@sunknudsen.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```

imported: 1

👍

### …or using PGP public key URL

Replace `https://sunknudsen.com/sunknudsen.asc` with signer’s public key URL.

```console
$ curl https://sunknudsen.com/sunknudsen.asc | gpg --import
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  2070  100  2070    0     0   1881      0  0:00:01  0:00:01 --:--:--  1899
gpg: key 8C9CA674C47CA060: 1 signature not checked due to a missing key
gpg: key 8C9CA674C47CA060: public key "Sun Knudsen <hello@sunknudsen.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
```

imported: 1

👍

### Verify signer’s PGP public key using fingerprint

Replace `hello@sunknudsen.com` with signer’s email and use published fingerprints to verify signer’s cryptographic identity (learn how [here](../how-to-encrypt-sign-and-decrypt-messages-using-gnupg-on-macos#verify-suns-pgp-public-key-using-fingerprint)).

```console
$ gpg --fingerprint hello@sunknudsen.com
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
pub   rsa4096 2019-10-17 [C]
      C4FB DDC1 6A26 2672 920D  0A0F C132 3A37 7DE1 4C8B
uid           [ unknown] Sun Knudsen <hello@sunknudsen.com>
sub   rsa4096 2019-10-17 [E] [expires: 2021-10-25]
sub   rsa4096 2019-10-17 [A] [expires: 2021-10-25]
sub   rsa4096 2019-10-17 [S] [expires: 2021-10-25]
```

### Verify [signed message](https://sunknudsen.com/static/media/cms/donate/donate-bitcoin.asc)

```console
$ gpg --verify donate-bitcoin.asc
gpg: Signature made Wed 29 Dec 10:32:32 2021 EST
gpg:                using EDDSA key 9C7887E1B5FCBCE2DFED0E1C02C43AD072D57783
gpg: Good signature from "Sun Knudsen <hello@sunknudsen.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: E786 274B C92B 47C2 3C1C  F44B 8C9C A674 C47C A060
     Subkey fingerprint: 9C78 87E1 B5FC BCE2 DFED  0E1C 02C4 3AD0 72D5 7783
```

Good signature

👍

### Verify signed [file](https://sunknudsen.com/static/media/privacy-guides/how-to-clean-uninstall-macos-apps-using-appcleaner-open-source-alternative/app-cleaner.sh) using [detached signature](https://sunknudsen.com/static/media/privacy-guides/how-to-clean-uninstall-macos-apps-using-appcleaner-open-source-alternative/app-cleaner.sh.asc)

```console
$ gpg --verify app-cleaner.sh.asc
gpg: assuming signed data in 'app-cleaner.sh'
gpg: Signature made Wed 29 Dec 10:42:13 2021 EST
gpg:                using EDDSA key 9C7887E1B5FCBCE2DFED0E1C02C43AD072D57783
gpg: Good signature from "Sun Knudsen <hello@sunknudsen.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: E786 274B C92B 47C2 3C1C  F44B 8C9C A674 C47C A060
     Subkey fingerprint: 9C78 87E1 B5FC BCE2 DFED  0E1C 02C4 3AD0 72D5 7783
```

Good signature

👍
