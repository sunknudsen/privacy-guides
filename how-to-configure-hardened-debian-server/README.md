<!--
Title: How to configure hardened Debian server
Description: Learn how to configure hardened Debian server.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2020-11-27T10:00:26.806Z
Listed: true
-->

# How to configure hardened Debian server

[![How to configure hardened Debian server](how-to-configure-hardened-debian-server.png)](https://www.youtube.com/watch?v=z8hizZRX5-4 "How to configure hardened Debian server")

## Requirements

- Virtual private server (VPS) or dedicated server running Debian 10 (buster)
- Linux or macOS computer

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command
- When copy/pasting commands that start with `cat << "EOF"`, select all lines at once (from `cat << "EOF"` to `EOF` inclusively) as they are part of the same (single) command

## Guide

### Step 1: create SSH key pair (on computer)

When asked for file in which to save key, enter `server`.

When asked for passphrase, use output from `openssl rand -base64 24` (and store passphrase in password manager).

Use `server.pub` public key when setting up server.

```console
$ mkdir ~/.ssh

$ cd ~/.ssh

$ ssh-keygen -t rsa -C "server"
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/sunknudsen/.ssh/id_rsa): server
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in server.
Your public key has been saved in server.pub.
The key fingerprint is:
SHA256:De1pasRJ2n0ggfRSWRJqrcensqboAc2i+/+/FxAo3xI server
The key's randomart image is:
+---[RSA 3072]----+
|     ..o=+.      |
|    . E=o+       |
|     o+o*.o      |
| o   .oOoB o     |
|o o   o.S.B .    |
|.o     o =..     |
|. .   . +  .     |
| . o  .+  .      |
|.o+.o+o.oo       |
+----[SHA256]-----+

$ cat server.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDP58i1vuFEe3zoHT+hZRh0YaXQY+ADa8OgBIoTji+AqzZRAa3ve8yDLwtoQKYpAZ2OcHoWDJP2pB/4unLJfKu6ILqKjRLkrnWvMGqcFs2QSVFg4ernmjiSAf3l2qrM+jxwElPEUo0Ht1GByEnWw2yfq0RNg0fukVrczWnUzvJMyhzhG2sjncFHIe2L6SPLlqRW46uHQBhFuHHb2gERV6smH/1ZS8YJtjq1klgVshhZWlBtodbIHo70owAeIpkeped966fSfzcAVksr3lTLR5jQyqgcTlDLj9vJn8nhGX0S/ETUs9dUNAOz0HWDvAaRyw95g/KWrctHvvng4VzjoU4qJlkjnhutoyDhz/medMnm4rkD6g6hOCkNKhMrCKby45TlMWFCZLjDwB70DZwqJChfWXlo0Ov0lah0a+ZgZ7Quz4yvzlrJt7vZkqFfr5LBI8AOB3yfFbeOZR564Q0jaH7C6yeRRvYVZkNCCZAVK9K2v1X7Bl0x42WN/MCzsA6embk= server
```

### Step 2: log in to server as root

Replace `185.112.147.115` with IP of server.

When asked for passphrase, enter passphrase from [step 1](#step-1-create-ssh-key-pair-on-computer).

```shell
ssh root@185.112.147.115 -i ~/.ssh/server
```

### Step 3: disable root Bash history

```shell
echo "HISTFILESIZE=0" >> ~/.bashrc
source ~/.bashrc
```

### Step 4: set root password

When asked for password, use output from `openssl rand -base64 24` (and store password in password manager).

```console
$ passwd
New password:
Retype new password:
passwd: password updated successfully
```

### Step 5: create server-admin user

When asked for password, use output from `openssl rand -base64 24` (and store password in password manager).

All other fields are optional, press <kbd>enter</kbd> to skip them and then press <kbd>Y</kbd>.

```console
$ adduser server-admin
Adding user `server-admin' ...
Adding new group `server-admin' (1000) ...
Adding new user `server-admin' (1000) with group `server-admin' ...
Creating home directory `/home/server-admin' ...
Copying files from `/etc/skel' ...
New password:
Retype new password:
passwd: password updated successfully
Changing the user information for server-admin
Enter the new value, or press ENTER for the default
	Full Name []:
	Room Number []:
	Work Phone []:
	Home Phone []:
	Other []:
Is the information correct? [Y/n] Y
```

### Step 6: copy root `authorized_keys` file to server-admin home folder

```shell
mkdir /home/server-admin/.ssh
cp /root/.ssh/authorized_keys /home/server-admin/.ssh/authorized_keys
chown -R server-admin:server-admin /home/server-admin/.ssh
```

### Step 7: log out

```shell
exit
```

### Step 8: log in as server-admin

Replace `185.112.147.115` with IP of server.

When asked for passphrase, enter passphrase from [step 1](#step-1-create-ssh-key-pair-on-computer).

```shell
ssh server-admin@185.112.147.115 -i ~/.ssh/server
```

### Step 9: disable server-admin Bash history

```shell
sed -i -E 's/^HISTSIZE=/#HISTSIZE=/' ~/.bashrc
sed -i -E 's/^HISTFILESIZE=/#HISTFILESIZE=/' ~/.bashrc
echo "HISTFILESIZE=0" >> ~/.bashrc
source ~/.bashrc
```

### Step 10: switch to root

When asked, enter root password.

```shell
su -
```

### Step 11: disable root login and password authentication

```shell
sed -i -E 's/^(#)?PermitRootLogin (prohibit-password|yes)/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i -E 's/^(#)?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh
```

### Step 12: update APT index and upgrade packages

#### Update APT index

```shell
apt update
```

#### Upgrade packages

```shell
apt upgrade -y
```

### Step 13: install and configure Vim

#### Install Vim

```shell
apt install -y vim
```

#### Configure Vim

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

### Step 14: set timezone (the following is for Montreal time)

See https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

```shell
timedatectl set-timezone America/Montreal
```

### Step 15: configure sysctl (if network is IPv4-only)

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

### Step 16: install iptables-persistent

When asked to save current IPv4 or IPv6 rules, answer `Yes`.

```shell
apt install -y iptables-persistent
```

### Step 17: configure iptables

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

### Step 18: log out and log in to confirm iptables didn’t block SSH

#### Log out

```shell
exit
exit
```

#### Log in

Replace `185.112.147.115` with IP of server.

When asked for passphrase, enter passphrase from [step 1](#step-1-create-ssh-key-pair-on-computer).

```shell
ssh server-admin@185.112.147.115 -i ~/.ssh/server
```

#### Switch to root

When asked, enter root password.

```shell
su -
```

### Step 19: make iptables rules persistent

```shell
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6
```

👍
