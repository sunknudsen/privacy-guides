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
- Linux or macOS computer

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command
- When copy/pasting commands that start with `cat << "EOF"`, select all lines at once (from `cat << "EOF"` to `EOF` inclusively) as they are part of the same (single) command

## Setup guide

### Step 1: log in to Raspberry Pi

Replace `10.0.1.248` with IP of Raspberry Pi.

When asked for password, enter password from [step 1](#step-1-create-ssh-key-pair-on-computer).

```shell
ssh pi@10.0.1.248 -i ~/.ssh/pi
```

### Step 2 (optional): install [Adafruit PiTFT monitor](https://www.adafruit.com/product/2423) drivers and disable console auto login

#### Install [Adafruit PiTFT monitor](https://www.adafruit.com/product/2423) drivers

> Heads-up: don’t worry about `PITFT Failed to disable unit: Unit file fbcp.service does not exist.`.

```shell
$ sudo apt update

$ sudo apt install -y git python3-pip

$ sudo pip3 install --upgrade adafruit-python-shell click==7.0

$ git clone https://github.com/adafruit/Raspberry-Pi-Installer-Scripts.git

$ cd Raspberry-Pi-Installer-Scripts

$ sudo python3 adafruit-pitft.py --display=28c --rotation=90 --install-type=console
```

#### Disable console auto login

```shell
sudo raspi-config
```

Select “System Options”, then “Boot / Auto Login”, then “Console” and finally “Finish”.

### Step 3: configure keyboard keymap

> Heads-up: following instructions are for [Raspberry Pi keyboard](https://www.raspberrypi.org/products/raspberry-pi-keyboard-and-hub/) (US model).

```shell
sudo raspi-config
```

Select “Localisation Options”, then “Keyboard”, then “Generic 105-key PC (intl.)”, then “Other”, then “English (US)”, then “English (US)”, then “The default for the keyboard layout”, then “No compose key” and finally “Finish”.

### Step 4: install dependencies

```shell
$ sudo apt update

$ sudo apt install -y fim imagemagick zbar-tools

$ pip3 install pillow qrcode --user

$ echo "export GPG_TTY=\"\$(tty)\"" >> ~/.bashrc

$ echo "export PATH=\$PATH:/home/pi/.local/bin" >> ~/.bashrc

$ source ~/.bashrc
```

### Step 5: download [qr-backup.sh](./qr-backup.sh) ([PGP signature](./qr-backup.sh.sig), [PGP public key](https://sunknudsen.com/sunknudsen.asc))

```shell
sudo curl -o /usr/local/sbin/qr-backup.sh https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/qr-backup.sh
sudo chmod +x /usr/local/sbin/qr-backup.sh
```

### Step 6: download [qr-restore.sh](./qr-restore.sh) ([PGP signature](./qr-restore.sh.sig), [PGP public key](https://sunknudsen.com/sunknudsen.asc))

```shell
sudo curl -o /usr/local/sbin/qr-restore.sh https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/qr-restore.sh
sudo chmod +x /usr/local/sbin/qr-restore.sh
```

### Step 7: download [qr-clone.sh](./qr-clone.sh) ([PGP signature](./qr-clone.sh.sig), [PGP public key](https://sunknudsen.com/sunknudsen.asc))

```shell
sudo curl -o /usr/local/sbin/qr-clone.sh https://sunknudsen.com/static/media/privacy-guides/how-to-create-encrypted-paper-backup/qr-clone.sh
sudo chmod +x /usr/local/sbin/qr-clone.sh
```

### Step 8: reboot

```shell
sudo systemctl reboot
```

👍

---

## Usage guide

### Create encrypted paper backup

```shell
qr-backup.sh
```

### Restore encrypted paper backup

```shell
qr-restore.sh
```

### Clone encrypted paper backup

```shell
qr-clone.sh
```

👍
