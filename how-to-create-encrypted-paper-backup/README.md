<!--
Title: How to create encrypted paper backup
Description: Learn how to create encrypted paper backup.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>, Alex Anderson <https://github.com/Serpent27>, Nico Kaiser <https://github.com/nicokaiser>, Daan Sprenkels <https://github.com/dsprenkels>
Reviewers:
Publication date: 2021-04-19T14:05:38.426Z
Listed: false
-->

# How to create encrypted paper backup

## Requirements

- [Hardened Raspberry Pi](../how-to-configure-hardened-raspberry-pi) 📦
- Raspberry Pi OS-compatible auto-focus HD USB webcam
- [Adafruit PiTFT monitor](https://www.adafruit.com/product/2423) (optional)
- macOS computer

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command
- When copy/pasting commands that start with `cat << "EOF"`, select all lines at once (from `cat << "EOF"` to `EOF` inclusively) as they are part of the same (single) command

## Setup guide

### Step 1: log in to Raspberry Pi

Replace `10.0.1.248` with IP of Raspberry Pi.

```shell
ssh pi@10.0.1.248 -i ~/.ssh/pi
```

### Step 2 (optional): install [Adafruit PiTFT monitor](https://www.adafruit.com/product/2423) drivers and disable console auto login

#### Install [Adafruit PiTFT monitor](https://www.adafruit.com/product/2423) drivers

> Heads-up: don’t worry about `PITFT Failed to disable unit: Unit file fbcp.service does not exist.`.

> Heads-up: when asked to reboot, type `n` and press enter.

```console
$ sudo apt update

$ sudo apt install -y git python3-pip

$ sudo pip3 install adafruit-python-shell click==7.0

$ git clone https://github.com/adafruit/Raspberry-Pi-Installer-Scripts.git

$ cd Raspberry-Pi-Installer-Scripts

$ sudo python3 adafruit-pitft.py --display=28c --rotation=90 --install-type=console

$ cd ~

$ rm -fr Raspberry-Pi-Installer-Scripts
```

#### Disable console auto login

> Heads-up: when asked to reboot, select “No” and press enter.

```shell
sudo raspi-config
```

Select “System Options”, then “Boot / Auto Login”, then “Console” and finally “Finish”.

### Step 3: configure keyboard keymap

> Heads-up: following instructions are for [Raspberry Pi keyboard](https://www.raspberrypi.org/products/raspberry-pi-keyboard-and-hub/) (US model).

> Heads-up: when asked to reboot, select “No” and press enter.

```shell
sudo raspi-config
```

Select “Localisation Options”, then “Keyboard”, then “Generic 105-key PC (intl.)”, then “Other”, then “English (US)”, then “English (US)”, then “The default for the keyboard layout”, then “No compose key” and finally “Finish”.

### Step 4: install dependencies available on repositories

```console
$ sudo apt update

$ sudo apt install -y expect fim imagemagick

$ pip3 install mnemonic pillow qrcode --user

$ echo -e "export GPG_TTY=\"\$(tty)\"\nexport PATH=\$PATH:/home/pi/.local/bin" >> ~/.bashrc

$ source ~/.bashrc
```

### Step 5: install [zbar](https://github.com/mchehab/zbar) from source

#### Install zbar dependencies

```console
$ sudo apt update

$ sudo apt install -y autopoint build-essential git libjpeg-dev libmagickwand-dev libtool libv4l-dev
```

#### Clone zbar repository

> Heads-up: replace `0.23.90` with [latest release](https://github.com/mchehab/zbar/releases/latest) semver.

```console
$ cd ~

$ git clone https://github.com/mchehab/zbar

$ cd zbar

$ git checkout 0.23.90
```

#### Configure, compile and install zbar

```console
$ autoreconf -vfi

$ ./configure --without-python

$ make

$ sudo make install

$ sudo ldconfig

$ cd ~

$ rm -fr zbar
```

### Step 6: install [sss-cli](https://github.com/dsprenkels/sss-cli) from source

#### Install [Rust](https://www.rust-lang.org/)

> Heads-up: when asked for installation option, select “Proceed with installation (default)”.

```shell
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

$ source ~/.bashrc
```

#### Install sss-cli

```console
$ cargo install --git https://github.com/dsprenkels/sss-cli --branch v0.1

$ cp ~/.cargo/bin/secret-share* ~/.local/bin/
```

### Step 7 (optional): install [Electrum](https://electrum.org/#home) (required to generate Electrum mnemonic)

#### Install Electrum dependencies

```shell
$ sudo apt update

$ sudo apt install -y libsecp256k1-0 python3-cryptography
```

#### Set Electrum release semver environment variable

> Heads-up: replace `4.1.2` with [latest release](https://electrum.org/#download) semver.

```shell
ELECTRUM_RELEASE_SEMVER=4.1.2
```

#### Download Electrum release and PGP signature

```shell
$ cd ~

$ curl -O "https://download.electrum.org/$ELECTRUM_RELEASE_SEMVER/Electrum-$ELECTRUM_RELEASE_SEMVER.tar.gz"

$ curl -O "https://download.electrum.org/$ELECTRUM_RELEASE_SEMVER/Electrum-$ELECTRUM_RELEASE_SEMVER.tar.gz.asc"
```

#### Import ThomasV’s PGP public key

```console
$ curl https://raw.githubusercontent.com/spesmilo/electrum/master/pubkeys/ThomasV.asc | gpg --import
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4739  100  4739    0     0  22459      0 --:--:-- --:--:-- --:--:-- 22459
gpg: /home/pi/.gnupg/trustdb.gpg: trustdb created
gpg: key 2BD5824B7F9470E6: public key "Thomas Voegtlin (https://electrum.org) <thomasv@electrum.org>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```

imported: 1

👍

#### Verify Electrum release using GnuPG (learn how [here](../how-to-verify-pgp-digital-signatures-using-gnupg-on-macos))

```console
$ gpg --verify Electrum-$ELECTRUM_RELEASE_SEMVER.tar.gz.asc
gpg: assuming signed data in 'Electrum-$ELECTRUM_RELEASE_SEMVER.tar.gz'
gpg: Signature made Thu 08 Apr 2021 09:47:30 EDT
gpg:                using RSA key 6694D8DE7BE8EE5631BED9502BD5824B7F9470E6
gpg: Good signature from "Thomas Voegtlin (https://electrum.org) <thomasv@electrum.org>" [unknown]
gpg:                 aka "ThomasV <thomasv1@gmx.de>" [unknown]
gpg:                 aka "Thomas Voegtlin <thomasv1@gmx.de>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 6694 D8DE 7BE8 EE56 31BE  D950 2BD5 824B 7F94 70E6
```

Good signature

👍

#### Install Electrum

```shell
$ pip3 install --user Electrum-$ELECTRUM_RELEASE_SEMVER.tar.gz

$ rm Electrum-$ELECTRUM_RELEASE_SEMVER.tar.gz*
```

### Step 8 (optional): install `screen` and [trezorcrl](https://wiki.trezor.io/Using_trezorctl_commands_with_Trezor) (required to validate integrity of [Trezor](https://trezor.io/) encrypted paper backups)

```console
$ sudo apt update

$ sudo apt install -y screen

$ pip3 install attrs trezor --user

$ sudo curl -o /etc/udev/rules.d/51-trezor.rules https://data.trezor.io/udev/51-trezor.rules
```

### Step 9: import Sun’s PGP public key (used to verify downloads bellow)

```console
$ curl https://sunknudsen.com/sunknudsen.asc | gpg --import
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6896  100  6896    0     0   6499      0  0:00:01  0:00:01 --:--:--  6499
gpg: key C1323A377DE14C8B: public key "Sun Knudsen <hello@sunknudsen.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```

imported: 1

👍

### Step 10: download and verify [create-bip39-mnemonic.py](./create-bip39-mnemonic.py)

```console
$ curl -o /home/pi/.local/bin/create-bip39-mnemonic.py https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/create-bip39-mnemonic.py
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   149  100   149    0     0    138      0  0:00:01  0:00:01 --:--:--   138

$ curl -o /home/pi/.local/bin/create-bip39-mnemonic.py.sig https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/create-bip39-mnemonic.py.sig
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   833  100   833    0     0    681      0  0:00:01  0:00:01 --:--:--   681

$ gpg --verify /home/pi/.local/bin/create-bip39-mnemonic.py.sig
gpg: assuming signed data in '/home/pi/.local/bin/create-bip39-mnemonic.py'
gpg: Signature made Thu 15 Apr 2021 12:54:22 EDT
gpg:                using RSA key A98CCD122243655B26FAFB611FA767862BBD1305
gpg: Good signature from "Sun Knudsen <hello@sunknudsen.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: C4FB DDC1 6A26 2672 920D  0A0F C132 3A37 7DE1 4C8B
     Subkey fingerprint: A98C CD12 2243 655B 26FA  FB61 1FA7 6786 2BBD 1305

$ chmod 600 /home/pi/.local/bin/create-bip39-mnemonic.py
```

Primary key fingerprint matches [published](../how-to-encrypt-sign-and-decrypt-messages-using-gnupg-on-macos#verify-suns-pgp-public-key-using-its-fingerprint) fingerprints

👍

Good signature

👍

### Step 11: download and verify [validate-bip39-mnemonic.py](./validate-bip39-mnemonic.py)

```console
$ curl -o /home/pi/.local/bin/validate-bip39-mnemonic.py https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/validate-bip39-mnemonic.py
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6217  100  6217    0     0   8234      0 --:--:-- --:--:-- --:--:--  8234

$ curl -o /home/pi/.local/bin/validate-bip39-mnemonic.py.sig https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/validate-bip39-mnemonic.py.sig
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6217  100  6217    0     0  10361      0 --:--:-- --:--:-- --:--:-- 10344

$ gpg --verify /home/pi/.local/bin/create-bip39-mnemonic.py.sig
gpg: assuming signed data in '/home/pi/.local/bin/create-bip39-mnemonic.py'
gpg: Signature made Thu 15 Apr 2021 12:54:22 EDT
gpg:                using RSA key A98CCD122243655B26FAFB611FA767862BBD1305
gpg: Good signature from "Sun Knudsen <hello@sunknudsen.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: C4FB DDC1 6A26 2672 920D  0A0F C132 3A37 7DE1 4C8B
     Subkey fingerprint: A98C CD12 2243 655B 26FA  FB61 1FA7 6786 2BBD 1305

$ chmod 600 /home/pi/.local/bin/validate-bip39-mnemonic.py
```

Primary key fingerprint matches [published](../how-to-encrypt-sign-and-decrypt-messages-using-gnupg-on-macos#verify-suns-pgp-public-key-using-its-fingerprint) fingerprints

👍

Good signature

👍

### Step 12: download and verify [qr-backup.sh](./qr-backup.sh)

```console
$ curl -o /home/pi/.local/bin/qr-backup.sh https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/qr-backup.sh
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3956  100  3956    0     0   3971      0 --:--:-- --:--:-- --:--:--  3967

$ curl -o /home/pi/.local/bin/qr-backup.sh.sig https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/qr-backup.sh.sig
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   833  100   833    0     0    620      0  0:00:01  0:00:01 --:--:--   620

$ gpg --verify /home/pi/.local/bin/qr-backup.sh.sig
gpg: assuming signed data in '/home/pi/.local/bin/qr-backup.sh'
gpg: Signature made Sun 18 Apr 2021 19:03:07 EDT
gpg:                using RSA key A98CCD122243655B26FAFB611FA767862BBD1305
gpg: Good signature from "Sun Knudsen <hello@sunknudsen.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: C4FB DDC1 6A26 2672 920D  0A0F C132 3A37 7DE1 4C8B
     Subkey fingerprint: A98C CD12 2243 655B 26FA  FB61 1FA7 6786 2BBD 1305

$ chmod 700 /home/pi/.local/bin/qr-backup.sh
```

Primary key fingerprint matches [published](../how-to-encrypt-sign-and-decrypt-messages-using-gnupg-on-macos#verify-suns-pgp-public-key-using-its-fingerprint) fingerprints

👍

Good signature

👍

### Step 13: download and verify [qr-restore.sh](./qr-restore.sh)

```console
$ curl -o /home/pi/.local/bin/qr-restore.sh https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/qr-restore.sh
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1904  100  1904    0     0   1715      0  0:00:01  0:00:01 --:--:--  1715

$ curl -o /home/pi/.local/bin/qr-restore.sh.sig https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/qr-restore.sh.sig
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   833  100   833    0     0    908      0 --:--:-- --:--:-- --:--:--   908

$ gpg --verify /home/pi/.local/bin/qr-restore.sh.sig
gpg: assuming signed data in '/home/pi/.local/bin/qr-restore.sh'
gpg: Signature made Sun 18 Apr 2021 18:47:17 EDT
gpg:                using RSA key A98CCD122243655B26FAFB611FA767862BBD1305
gpg: Good signature from "Sun Knudsen <hello@sunknudsen.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: C4FB DDC1 6A26 2672 920D  0A0F C132 3A37 7DE1 4C8B
     Subkey fingerprint: A98C CD12 2243 655B 26FA  FB61 1FA7 6786 2BBD 1305

$ chmod 700 /home/pi/.local/bin/qr-restore.sh
```

Primary key fingerprint matches [published](../how-to-encrypt-sign-and-decrypt-messages-using-gnupg-on-macos#verify-suns-pgp-public-key-using-its-fingerprint) fingerprints

👍

Good signature

👍

### Step 14: download and verify [qr-clone.sh](./qr-clone.sh)

```console
$ curl -o /home/pi/.local/bin/qr-clone.sh https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/qr-clone.sh
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   481  100   481    0     0    440      0  0:00:01  0:00:01 --:--:--   440

$ curl -o /home/pi/.local/bin/qr-clone.sh.sig https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/qr-clone.sh.sig
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   833  100   833    0     0    783      0  0:00:01  0:00:01 --:--:--   784

$ gpg --verify /home/pi/.local/bin/qr-clone.sh.sig
gpg: assuming signed data in '/home/pi/.local/bin/qr-clone.sh'
gpg: Signature made Sat 17 Apr 2021 15:37:07 EDT
gpg:                using RSA key A98CCD122243655B26FAFB611FA767862BBD1305
gpg: Good signature from "Sun Knudsen <hello@sunknudsen.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: C4FB DDC1 6A26 2672 920D  0A0F C132 3A37 7DE1 4C8B
     Subkey fingerprint: A98C CD12 2243 655B 26FA  FB61 1FA7 6786 2BBD 1305

$ chmod 700 /home/pi/.local/bin/qr-clone.sh
```

Primary key fingerprint matches [published](../how-to-encrypt-sign-and-decrypt-messages-using-gnupg-on-macos#verify-suns-pgp-public-key-using-its-fingerprint) fingerprints

👍

Good signature

👍

### Step 15: download and verify [secure-erase.sh](./secure-erase.sh)

```console
$ curl -o /home/pi/.local/bin/secure-erase.sh https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/secure-erase.sh
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1283  100  1283    0     0   1189      0  0:00:01  0:00:01 --:--:--  1189

$ curl -o /home/pi/.local/bin/secure-erase.sh.sig https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/secure-erase.sh.sig
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   833  100   833    0     0    944      0 --:--:-- --:--:-- --:--:--   944

$ gpg --verify /home/pi/.local/bin/secure-erase.sh.sig
gpg: assuming signed data in '/home/pi/.local/bin/secure-erase.sh'
gpg: Signature made Sat 17 Apr 2021 15:37:12 EDT
gpg:                using RSA key A98CCD122243655B26FAFB611FA767862BBD1305
gpg: Good signature from "Sun Knudsen <hello@sunknudsen.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: C4FB DDC1 6A26 2672 920D  0A0F C132 3A37 7DE1 4C8B
     Subkey fingerprint: A98C CD12 2243 655B 26FA  FB61 1FA7 6786 2BBD 1305

$ chmod 700 /home/pi/.local/bin/secure-erase.sh
```

Primary key fingerprint matches [published](../how-to-encrypt-sign-and-decrypt-messages-using-gnupg-on-macos#verify-suns-pgp-public-key-using-its-fingerprint) fingerprints

👍

Good signature

👍

### Step 16: make filesystem read-only

> Heads-up: shout-out to Nico Kaiser for his amazing [guide](https://gist.github.com/nicokaiser/08aa5b7b3958f171cf61549b70e8a34b) on how to configure a read-only Raspberry Pi.

#### Disable swap

```shell
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo systemctl disable dphys-swapfile.service
```

#### Remove `dphys-swapfile` `fake-hwclock` and `logrotate`

```shell
sudo apt remove -y --purge dphys-swapfile fake-hwclock logrotate
```

#### Link `/etc/console-setup` to `/tmp/console-setup`

```shell
sudo mv /etc/console-setup /tmp/console-setup
sudo ln -s /tmp/console-setup /etc/console-setup
```

#### Link `/etc/resolv.conf` to `/tmp/resolv.conf`

```shell
sudo mv /etc/resolv.conf /tmp/resolv.conf
sudo ln -s /tmp/resolv.conf /etc/resolv.conf
```

#### Link `/home/pi/.gnupg` to `/tmp/pi/.gnupg`

```shell
mkdir -m 700 /tmp/pi
mv /home/pi/.gnupg /tmp/pi/.gnupg
ln -s /tmp/pi/.gnupg /home/pi/.gnupg
```

#### Enable `tmp.mount` service

```shell
echo -e "D /tmp 1777 root root -\nD /tmp/console-setup 1700 root root -\nD /tmp/pi 1700 pi pi -\nD /tmp/pi/.gnupg 1700 pi pi -\nD /var/tmp 1777 root root -" | sudo tee /etc/tmpfiles.d/tmp.conf
sudo cp /usr/share/systemd/tmp.mount /etc/systemd/system/
sudo systemctl enable tmp.mount
```

#### Edit `/boot/cmdline.txt`

```shell
sudo cp /boot/cmdline.txt /boot/cmdline.txt.backup
sudo sed -i 's/fsck.repair=yes/fsck.repair=skip/' /boot/cmdline.txt
sudo sed -i '$ s/$/ fastboot noswap ro systemd.volatile=state/' /boot/cmdline.txt
```

#### Edit `/etc/fstab`

```shell
sudo cp /etc/fstab /etc/fstab.backup
sudo sed -i -e 's/vfat\s*defaults\s/vfat defaults,ro/' /etc/fstab
sudo sed -i -e 's/ext4\s*defaults,noatime\s/ext4 defaults,noatime,ro,noload/' /etc/fstab
```

### Step 17: disable Wi-Fi (if not using ethernet)

```shell
echo "dtoverlay=disable-wifi" | sudo tee -a /boot/config.txt
```

### Step 18: disable `dhcpcd`, `networking` and `wpa_supplicant` services and “fix” `rfkill` bug

```console
$ sudo systemctl disable dhcpcd networking wpa_supplicant

$ sudo rm /etc/profile.d/wifi-check.sh
```

### Step 19: delete macOS hidden files (if present)

```shell
sudo rm -fr /boot/.fseventsd /boot/.DS_Store /boot/.Spotlight-V100
```

### Step 20: reboot

```shell
sudo systemctl reboot
```

> WARNING: DO NOT CONNECT RASPBERRY PI TO NETWORK EVER AGAIN WITHOUT REINSTALLING RASPBERRY PI OS FIRST (DEVICE IS NOW "READ-ONLY" AND “COLD”).

### Step 21 (optional): disable auto-mount of `boot` volume (on macOS)

> Heads-up: done to prevent macOS from writing [hidden files](#step-16-delete-macos-hidden-files-if-present) to `boot` volume which would invalidate stored SHA512 hash of micro SD card.

Insert micro SD card into macOS computer, run following and eject card.

```shell
volume_path="/Volumes/boot"
volume_uuid=$(diskutil info "$volume_path" | awk '/Volume UUID:/ { print $3 }')
echo "UUID=$volume_uuid none msdos rw,noauto" | sudo tee -a /etc/fstab
```

### Step 22 (optional): compute SHA512 hash of micro SD card and store in password manager (on macOS)

Run `diskutil list` to find disk ID of micro SD card with “Raspberry Pi OS Lite” installed (`disk2` in the following example).

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

$ sudo diskutil unmountDisk /dev/diskn
Unmount of all volumes on disk2 was successful

$ sudo openssl dgst -sha512 /dev/rdiskn
SHA512(/dev/rdisk2)= 353af7e9bd78d7d98875f0e2a58da3d7cdfc494f2ab5474b2ab4a8fd212ac6a37c996d54f6c650838adb61e4b30801bcf1150081f6dbb51998cf33a74fa7f0fe
```

👍

---

## Usage guide

### Create encrypted paper backup

```console
$ qr-backup.sh --help
Usage: qr-backup.sh [options]

Options:
  --create-bip39-mnemonic      create BIP39 mnemonic
  --create-electrum-mnemonic   create Electrum mnemonic
  --validate-bip39-mnemonic    validate if secret is valid BIP39 mnemonic
  --shamir-secret-sharing      split secret using Shamir Secret Sharing
  --number-of-shares           number of shares (defaults to 5)
  --share-threshold            shares required to access secret (defaults to 3)
  --no-qr                      disable show SHA512 hash as QR code prompt
  --label <label>              print label after short hash
  -h, --help                   display help for command

$ qr-backup.sh
Format USB flash drive? (y or n)?
y
mkfs.fat 4.1 (2017-01-24)
Type secret and press enter (again)
this is a test yo
-----BEGIN PGP MESSAGE-----

jA0ECQMKmFCBKHBUX8z/0kUBxi8eP7LRqP0WgOF+VgTMYuvix7AMxWR/TRM+zQk/
i9JLr52Odmxv23jEC/KfAUdigAqhs3/GJRtwWuC2IR5NzfBNvXM=
=xkQH
-----END PGP MESSAGE-----
SHA512 hash: 177cc163d89498b859ce06f6f2ac1cd2f9f493b848cdf08746bfb2f4a8bf958ebb45eb70f8f20141c12aa65387ee0545b7c0757cf8d6c808e2fa449fad0e986a
SHA512 short hash: 177cc163
Show SHA512 hash as QR code? (y or n)?
n
Done
```

Done

👍

The following image is now available on USB flash drive.

![177cc163](./177cc163.jpg?shadow=1)

### Restore encrypted paper backup

> Heads-up: use `--word-list` to split secret into word list.

```console
$ qr-restore.sh --help
Usage: qr-restore.sh [options]

Options:
  --shamir-secret-sharing    combine secret using Shamir Secret Sharing
  --share-threshold          shares required to access secret (defaults to 3)
  --word-list                split secret into word list
  -h, --help                 display help for command

$ qr-restore.sh
Scan QR code…
-----BEGIN PGP MESSAGE-----

jA0ECQMKmFCBKHBUX8z/0kUBxi8eP7LRqP0WgOF+VgTMYuvix7AMxWR/TRM+zQk/
i9JLr52Odmxv23jEC/KfAUdigAqhs3/GJRtwWuC2IR5NzfBNvXM=
=xkQH
-----END PGP MESSAGE-----
SHA512 hash: 177cc163d89498b859ce06f6f2ac1cd2f9f493b848cdf08746bfb2f4a8bf958ebb45eb70f8f20141c12aa65387ee0545b7c0757cf8d6c808e2fa449fad0e986a
SHA512 short hash: 177cc163
Show secret? (y or n)?
y
gpg: AES256 encrypted data
gpg: encrypted with 1 passphrase
Secret: this is a test yo
Done
```

Done

👍

### Clone encrypted paper backup

```console
$ qr-clone.sh --help
Usage: qr-clone.sh [options]

Options:
  --duplicate            duplicate content
  --qr-restore-options   see `qr-restore.sh --help`
  --qr-backup-options    see `qr-backup.sh --help`
  -h, --help             display help for command

$ qr-clone.sh
Scan QR code…
-----BEGIN PGP MESSAGE-----

jA0ECQMKmFCBKHBUX8z/0kUBxi8eP7LRqP0WgOF+VgTMYuvix7AMxWR/TRM+zQk/
i9JLr52Odmxv23jEC/KfAUdigAqhs3/GJRtwWuC2IR5NzfBNvXM=
=xkQH
-----END PGP MESSAGE-----
SHA512 hash: 177cc163d89498b859ce06f6f2ac1cd2f9f493b848cdf08746bfb2f4a8bf958ebb45eb70f8f20141c12aa65387ee0545b7c0757cf8d6c808e2fa449fad0e986a
SHA512 short hash: 177cc163
Show secret? (y or n)?
y
gpg: AES256 encrypted data
gpg: encrypted with 1 passphrase
Secret: this is a test yo
Done
Backing up…
Format USB flash drive? (y or n)?
y
mkfs.fat 4.1 (2017-01-24)
-----BEGIN PGP MESSAGE-----

jA0ECQMKAWdJZylXXDf/0kUB/rRdX1+5OYVh7iwzM0julwIfDe57slc6LeGeRtDa
KfY4QZkCrseEoZdSZd5mGYQ0ItW9exfBiXN5AU+rbEmzF6VuEWY=
=ul1g
-----END PGP MESSAGE-----
SHA512 hash: 524d8219b17aad59d7cec70f901dfdd449d15f21479740b0111b621cc870e6d82f2f4a0ea8303fb478b24500195325be9c3256d4d5b19700a1cdd1329fc2c71f
SHA512 short hash: 524d8219
Show SHA512 hash as QR code? (y or n)?
n
Done
```

Done

👍

The following image is now available on USB flash drive.

![524d8219](./524d8219.jpg?shadow=1)

### Secure erase flash drive

```console
$ secure-erase.sh --help
Usage: secure-erase.sh [options]

Options:
  --rounds <rounds>  overwrite n times (defauls to 3)
  --zero             overwrite with zeros obfuscating secure erase
  -h, --help         display help for command

$ secure-erase.sh
Secure erase USB flash drive? (y or n)?
y
Erasing… (iteration 1 of 3)
dd: error writing '/dev/sda1': No space left on device
1868+0 records in
1867+0 records out
1957691392 bytes (2.0 GB, 1.8 GiB) copied, 181.888 s, 10.8 MB/s
Erasing… (iteration 2 of 3)
dd: error writing '/dev/sda1': No space left on device
1868+0 records in
1867+0 records out
1957691392 bytes (2.0 GB, 1.8 GiB) copied, 195.606 s, 10.0 MB/s
Erasing… (iteration 3 of 3)
dd: error writing '/dev/sda1': No space left on device
1868+0 records in
1867+0 records out
1957691392 bytes (2.0 GB, 1.8 GiB) copied, 195.558 s, 10.0 MB/s
Done
```

Done

👍
