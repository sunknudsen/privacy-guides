<!--
Title: How to create encrypted paper backup
Description: Learn how to create encrypted paper backup.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>, Alex Anderson <https://github.com/Serpent27>
Reviewers:
Publication date: 2021-02-23T21:53:38.495Z
Listed: true
-->

# How to create encrypted paper backup

## Requirements

- [Hardened Raspberry Pi](../how-to-configure-hardened-raspberry-pi) 📦
- [Adafruit PiTFT monitor](https://www.adafruit.com/product/2423) (optional)
- macOS computer

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command
- When copy/pasting commands that start with `cat << "EOF"`, select all lines at once (from `cat << "EOF"` to `EOF` inclusively) as they are part of the same (single) command

## Setup guide

### Step 1: log in to Raspberry Pi

Replace `10.0.1.248` with IP of Raspberry Pi.

When asked for passphrase, enter passphrase from [step 1](#step-1-create-ssh-key-pair-on-computer).

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

$ sudo pip3 install --upgrade adafruit-python-shell click==7.0

$ git clone https://github.com/adafruit/Raspberry-Pi-Installer-Scripts.git

$ cd Raspberry-Pi-Installer-Scripts

$ sudo python3 adafruit-pitft.py --display=28c --rotation=90 --install-type=console
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

### Step 4: install dependencies

```console
$ sudo apt update

$ sudo apt install -y fim imagemagick zbar-tools

$ pip3 install pillow qrcode --user

$ echo "export GPG_TTY=\"\$(tty)\"" >> ~/.bashrc

$ echo "export PATH=\$PATH:/home/pi/.local/bin" >> ~/.bashrc

$ source ~/.bashrc
```

### Step 5: download [bip39.txt](./bip39.txt) ([PGP signature](./bip39.txt.sig), [PGP public key](https://sunknudsen.com/sunknudsen.asc))

```shell
sudo curl -o /usr/local/sbin/bip39.txt https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/bip39.txt
```

### Step 6: download [qr-backup.sh](./qr-backup.sh) ([PGP signature](./qr-backup.sh.sig), [PGP public key](https://sunknudsen.com/sunknudsen.asc))

```shell
sudo curl -o /usr/local/sbin/qr-backup.sh https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/qr-backup.sh
sudo chmod +x /usr/local/sbin/qr-backup.sh
```

### Step 7: download [qr-restore.sh](./qr-restore.sh) ([PGP signature](./qr-restore.sh.sig), [PGP public key](https://sunknudsen.com/sunknudsen.asc))

```shell
sudo curl -o /usr/local/sbin/qr-restore.sh https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/qr-restore.sh
sudo chmod +x /usr/local/sbin/qr-restore.sh
```

### Step 8: download [qr-clone.sh](./qr-clone.sh) ([PGP signature](./qr-clone.sh.sig), [PGP public key](https://sunknudsen.com/sunknudsen.asc))

```shell
sudo curl -o /usr/local/sbin/qr-clone.sh https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/qr-clone.sh
sudo chmod +x /usr/local/sbin/qr-clone.sh
```

### Step 9: download [secure-erase.sh](./secure-erase.sh) ([PGP signature](./secure-erase.sh.sig), [PGP public key](https://sunknudsen.com/sunknudsen.asc))

```shell
sudo curl -o /usr/local/sbin/secure-erase.sh https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/secure-erase.sh
sudo chmod +x /usr/local/sbin/secure-erase.sh
```

### Step 10: disable Wi-Fi (if not using ethernet) or disconnect ethernet cable

> WARNING: DO NOT CONNECT RASPBERRY PI TO NETWORK EVER AGAIN WITHOUT REINSTALLING RASPBERRY PI OS FIRST (DEVICE IS NOW “COLD”).

```shell
echo "dtoverlay=disable-wifi" | sudo tee -a /boot/config.txt
```

### Step 11: reboot

```shell
sudo systemctl reboot
```

👍

---

## Usage guide

### Create encrypted paper backup

> Heads-up: use `--bip39` to test secret against BIP39 [word list](https://raw.githubusercontent.com/bitcoin/bips/master/bip-0039/english.txt).

```console
$ qr-backup.sh --help
Usage: qr-backup.sh [options]

Options:
  --bip39      test secret against BIP39 word list
  -h, --help   display help for command

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

The following image is now available on USB flash drive.

![177cc163](./177cc163.jpg?shadow=1)

### Restore encrypted paper backup

> Heads-up: use `--word-list` to split secret into word list.

```console
$ qr-restore.sh
Usage: qr-restore.sh [options]

Options:
  --word-list    split secret into word list
  -h, --help     display help for command

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

### Clone encrypted paper backup

```console
$ qr-clone.sh --help
Usage: qr-clone.sh [options]

Options:
  -h, --help   display help for command

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

The following image is now available on USB flash drive.

![524d8219](./524d8219.jpg?shadow=1)

### Secure erase flash drive

```console
$ secure-erase.sh --help
Usage: secure-erase.sh [options]

Options:
  --iterations   overwrite n times (defauls to 3)
  --zero         overwrite with zeros to hide secure erase
  -h, --help     display help for command

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

👍
