<!--
Title: How to configure hardened Raspberry Pi
Description: Learn how to configure hardened Raspberry Pi.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2020-11-27T10:00:26.807Z
Listed: true
-->

# How to configure hardened Raspberry Pi

[![How to configure hardened Raspberry Pi](how-to-configure-hardened-raspberry-pi.png)](https://www.youtube.com/watch?v=6R8uKdstnts "How to configure hardened Raspberry Pi")

## Requirements

- [Raspberry Pi](https://www.raspberrypi.org/)
- Power adapter, keyboard and HDMI cable (and SD card reader if computer doesn’t have one built-in)
- macOS computer

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command
- When copy/pasting commands that start with `cat << "EOF"`, select all lines at once (from `cat << "EOF"` to `EOF` inclusively) as they are part of the same (single) command

## Guide

### Step 1: create SSH key pair (on macOS)

When asked for file in which to save key, enter `pi`.

When asked for passphrase, use output from `openssl rand -base64 24` (and store passphrase in password manager).

```console
$ mkdir -p ~/.ssh

$ cd ~/.ssh

$ ssh-keygen -t rsa -C "pi"
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/sunknudsen/.ssh/id_rsa): pi
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in pi.
Your public key has been saved in pi.pub.
The key fingerprint is:
SHA256:NZkr0Bmu6tpQfDp2GHTIPyBz253uZk/gOmoqzEszGM0 pi
The key's randomart image is:
+---[RSA 3072]----+
|        .        |
|   . . o o o     |
|  o * o + =      |
| o * * + o o     |
|. E = * S .      |
|.. . * + o       |
|++. * . o .      |
|ooo=.o.oo.       |
| o+++..+...      |
+----[SHA256]-----+

$ cat pi.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCzQpX9uqDP8L2gSZNJxYEi04Y1pZWz28v4zANY5dU6M35OFzXZcRcBqi2ZxiQofgxRrX9QlAcmcPFz8/CkpPw2WgQTflm+46ZrVEZcwwGwJsJwm7QVLQLd44/xtejEvMjzsuYDjJ1q4WhEvMSleTfOrix4yP0mjn83Zk1l6AMxR5J8DDumiHsGSYfcp+1XS9x4r4HP0mS2RpIy3rcoxLoJaYEKvVTj9qdvPMK7SDymZcvuBsgObEARVr77q4qhUfTP+xR91hHNEYD9FnCHF3qQBzlTlmTwpwhH6vOdWE3uUXCug9Ugw42Zj3PW0zd5rQ7EEpD9SDLbUqajpn2M5AlhkS9OrLpnIptocetRKNI9HzyAV1KqdNiQeL7/59d4y+HuZ9y032SaNzR1fw0nYMoHzTN9d+zPvziDZ183/pwtEXZNVVGzYO1r56n3S4vLx8YCpYqiHYVQVDF8aweoHYs3dAGAfPxmQ85+45UKpFR18XSGCqCO2fwbyTGDhkxCzU= pi
```

### Step 2: generate heredoc (the output of following command will be used at [step 10](#step-10-configure-pi-ssh-authorized-keys))

```shell
cat << EOF
cat << "_EOF" > ~/.ssh/authorized_keys
$(cat ~/.ssh/pi.pub)
_EOF
EOF
```

### Step 3: download latest version of [Raspberry Pi OS Lite](https://www.raspberrypi.org/software/operating-systems/)

### Step 4: clone “Raspberry Pi OS Lite”to SD card

> WARNING: DO NOT RUN THE FOLLOWING COMMANDS AS-IS.

Run `diskutil list` to find disk ID of SD card to overwrite with “Raspberry Pi OS Lite” (`disk2` in the following example).

Replace `diskn` and `rdiskn` with disk ID of SD card (`disk2` and `rdisk2` in the following example) and `2021-03-04-raspios-buster-armhf-lite.img` with current image.

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

$ sudo dd bs=1m if=$HOME/Downloads/2021-03-04-raspios-buster-armhf-lite.img of=/dev/rdiskn
1772+0 records in
1772+0 records out
1858076672 bytes transferred in 40.449002 secs (45936280 bytes/sec)

$ sudo diskutil unmountDisk /dev/diskn
Unmount of all volumes on disk2 was successful
```

### Step 5: log in as pi (using keyboard) and change password using `passwd`

> Heads-up: current password is `raspberry`.

```console
$ passwd
Changing password for pi.
Current password:
New password:
Retype new password:
passwd: password updated successfully
```

### Step 6: configure Wi-Fi (if not using ethernet)

```shell
sudo raspi-config
```

Select “System Options”, then “Wireless LAN”, choose country, then select “OK”, enter “SSID”, enter passphrase.

### Step 7: enable SSH

```shell
sudo raspi-config
```

Select “Interface Options”, then “SSH”, then “Yes”, then “OK” and finally “Finish”.

When asked if you wish to reboot, select “No”.

### Step 8: find IP of Raspberry Pi (see `eth0` if using ethernet or `wlan0` if using Wi-Fi)

```shell
ip a
```

### Step 9: log in to Raspberry Pi over SSH

Replace `10.0.1.248` with IP of Raspberry Pi.

When asked for passphrase, enter passphrase from [step 5](#step-5-log-in-as-pi-using-keyboard-and-change-password-using-passwd).

```shell
ssh pi@10.0.1.248
```

### Step 10: configure pi SSH authorized keys

#### Create `.ssh` folder

```shell
mkdir -p ~/.ssh
```

#### Create `~/.ssh/authorized_keys` using heredoc generated at [step 2](#step-2-generate-heredoc-the-output-of-following-command-will-be-used-at-step-10)

```shell
cat << "_EOF" > ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCzQpX9uqDP8L2gSZNJxYEi04Y1pZWz28v4zANY5dU6M35OFzXZcRcBqi2ZxiQofgxRrX9QlAcmcPFz8/CkpPw2WgQTflm+46ZrVEZcwwGwJsJwm7QVLQLd44/xtejEvMjzsuYDjJ1q4WhEvMSleTfOrix4yP0mjn83Zk1l6AMxR5J8DDumiHsGSYfcp+1XS9x4r4HP0mS2RpIy3rcoxLoJaYEKvVTj9qdvPMK7SDymZcvuBsgObEARVr77q4qhUfTP+xR91hHNEYD9FnCHF3qQBzlTlmTwpwhH6vOdWE3uUXCug9Ugw42Zj3PW0zd5rQ7EEpD9SDLbUqajpn2M5AlhkS9OrLpnIptocetRKNI9HzyAV1KqdNiQeL7/59d4y+HuZ9y032SaNzR1fw0nYMoHzTN9d+zPvziDZ183/pwtEXZNVVGzYO1r56n3S4vLx8YCpYqiHYVQVDF8aweoHYs3dAGAfPxmQ85+45UKpFR18XSGCqCO2fwbyTGDhkxCzU= pi
_EOF
```

### Step 11: log out

```shell
exit
```

### Step 12: log in

Replace `10.0.1.248` with IP of Raspberry Pi.

When asked for passphrase, enter passphrase from [step 1](#step-1-create-ssh-key-pair-on-macos).

```shell
ssh pi@10.0.1.248 -i ~/.ssh/pi
```

### Step 13: disable pi Bash history

```shell
sed -i -E 's/^HISTSIZE=/#HISTSIZE=/' ~/.bashrc
sed -i -E 's/^HISTFILESIZE=/#HISTFILESIZE=/' ~/.bashrc
echo "HISTFILESIZE=0" >> ~/.bashrc
history -c; history -w
source ~/.bashrc
```

### Step 14: disable pi sudo `nopassword` “feature”

```shell
sudo rm /etc/sudoers.d/010_*
```

### Step 15: configure pi `.vimrc`

```shell
cat << "EOF" > ~/.vimrc
set encoding=UTF-8
set termencoding=UTF-8
set nocompatible
set backspace=indent,eol,start
set autoindent
set tabstop=2
set shiftwidth=2
set expandtab
set smarttab
set ruler
set paste
syntax on
EOF
```

### Step 16: switch to root

```shell
sudo su -
```

### Step 17: disable root Bash history

```shell
echo "HISTFILESIZE=0" >> ~/.bashrc
history -c; history -w
source ~/.bashrc
```

### Step 18: set root password

When asked for password, use output from `openssl rand -base64 24` (and store password in password manager).

```console
$ passwd
New password:
Retype new password:
passwd: password updated successfully
```

### Step 19: configure root `.vimrc`

```shell
cat << "EOF" > ~/.vimrc
set encoding=UTF-8
set termencoding=UTF-8
set nocompatible
set backspace=indent,eol,start
set autoindent
set tabstop=2
set shiftwidth=2
set expandtab
set smarttab
set ruler
set paste
syntax on
EOF
```

### Step 20: disable root login and password authentication

```shell
sed -i -E 's/^(#)?PermitRootLogin (prohibit-password|yes)/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i -E 's/^(#)?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh
```

### Step 21: disable Bluetooth and Wi-Fi

> Heads-up: will take effect after reboot.

#### Disable Bluetooth

```shell
echo "dtoverlay=disable-bt" >> /boot/config.txt
```

#### Disable Wi-Fi (if using ethernet)

```shell
echo "dtoverlay=disable-wifi" >> /boot/config.txt
```

### Step 22: update APT index, install `iptables-persistent` and Vim and upgrade system

#### Update APT index

```shell
apt update
```

#### Install `iptables-persistent` and Vim

When asked to save current IPv4 or IPv6 rules, answer `Yes`.

```shell
apt install -y iptables-persistent vim
```

#### Upgrade packages

> Heads-up: if asked which version of `/etc/ssh/sshd_config` to keep, select “keep the local version currently installed”.

```shell
apt upgrade -y
```

### Step 23: reboot

```shell
systemctl reboot
```

### Step 24: log in

Replace `10.0.1.248` with IP of Raspberry Pi.

When asked for passphrase, enter passphrase from [step 1](#step-1-create-ssh-key-pair-on-macos).

```shell
ssh pi@10.0.1.248 -i ~/.ssh/pi
```

### Step 25: switch to root

```shell
sudo su -
```

### Step 26: set timezone (the following is for Montreal time)

See https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

```shell
timedatectl set-timezone America/Montreal
```

### Step 27: configure sysctl (if network is IPv4-only)

> Heads-up: only run the following if network is IPv4-only.

```shell
cp /etc/sysctl.conf /etc/sysctl.conf.backup
cat << "EOF" >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
sysctl -p
```

### Step 28: configure iptables

```shell
iptables -N SSH_BRUTE_FORCE_MITIGATION
iptables -A SSH_BRUTE_FORCE_MITIGATION -m recent --name SSH --set
iptables -A SSH_BRUTE_FORCE_MITIGATION -m recent --name SSH --update --seconds 300 --hitcount 10 -m limit --limit 1/second --limit-burst 100 -j LOG --log-prefix "iptables[ssh-brute-force]: "
iptables -A SSH_BRUTE_FORCE_MITIGATION -m recent --name SSH --update --seconds 300 --hitcount 10 -j DROP
iptables -A SSH_BRUTE_FORCE_MITIGATION -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 22 --syn -m conntrack --ctstate NEW -j SSH_BRUTE_FORCE_MITIGATION
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 123 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -P FORWARD DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP
```

If network is IPv4-only, run:

```shell
ip6tables -P FORWARD DROP
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
```

If network is dual stack (IPv4 + IPv6) run:

```shell
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type destination-unreachable -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type packet-too-big -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type time-exceeded -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type parameter-problem -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type router-advertisement -m hl --hl-eq 255 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type neighbor-solicitation -m hl --hl-eq 255 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type neighbor-advertisement -m hl --hl-eq 255 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type redirect -m hl --hl-eq 255 -j ACCEPT
ip6tables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT
ip6tables -A OUTPUT -p ipv6-icmp --icmpv6-type destination-unreachable -j ACCEPT
ip6tables -A OUTPUT -p ipv6-icmp --icmpv6-type packet-too-big -j ACCEPT
ip6tables -A OUTPUT -p ipv6-icmp --icmpv6-type time-exceeded -j ACCEPT
ip6tables -A OUTPUT -p ipv6-icmp --icmpv6-type parameter-problem -j ACCEPT
ip6tables -A OUTPUT -p ipv6-icmp --icmpv6-type router-solicitation -m hl --hl-eq 255 -j ACCEPT
ip6tables -A OUTPUT -p ipv6-icmp --icmpv6-type neighbour-solicitation -m hl --hl-eq 255 -j ACCEPT
ip6tables -A OUTPUT -p ipv6-icmp --icmpv6-type neighbour-advertisement -m hl --hl-eq 255 -j ACCEPT
ip6tables -A OUTPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT
ip6tables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
ip6tables -A OUTPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
ip6tables -A OUTPUT -p udp --dport 123 -m state --state NEW -j ACCEPT
ip6tables -A OUTPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT
ip6tables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
ip6tables -P FORWARD DROP
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
```

### Step 29: log out and log in to confirm iptables didn’t block SSH

#### Log out

```shell
exit
exit
```

#### Log in

Replace `10.0.1.248` with IP of Raspberry Pi.

```shell
ssh pi@10.0.1.248 -i ~/.ssh/pi
```

### Step 30: switch to root

```shell
sudo su -
```

### Step 31: make iptables rules persistent

```shell
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6
```

👍
