<!--
Title: How to self-host a hardened strongSwan IKEv2/IPsec VPN server for iOS and macOS
Description: Learn how to self-host a hardened strongSwan IKEv2/IPsec VPN server for iOS and macOS.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Publication date: 2020-07-31T12:39:56.680Z
-->

# How to self-host a hardened strongSwan IKEv2/IPsec VPN server for iOS and macOS

[![How to self-host a hardened strongSwan IKEv2/IPsec VPN server for iOS and macOS - YouTube](how-to-self-host-a-hardened-strongswan-ikev2-ipsec-vpn-server-for-ios-and-macos.png)](https://www.youtube.com/watch?v=HY3F_vHuTFQ "How to self-host a hardened strongSwan IKEv2/IPsec VPN server for iOS and macOS - YouTube")

> Heads up: when following this guide on IPv4-only servers (which is totally fine if one knows what one is doing), it’s likely IPv6 traffic will leak on iOS when clients are connected to carriers or ISPs running dual stack (IPv4 + IPv6) infrastructure. Leaks can be mitigated on iOS (cellular-only) and on macOS by following this [guide](../how-to-disable-ipv6-on-ios-cellular-only-and-macos-and-why-it-s-a-big-deal-for-privacy).

## Requirements

- Virtual private server (VPS) or dedicated server running Debian 10 (buster) with public IPv4 address
- Computer running macOS Mojave or Catalina
- Phone running iOS 12 or 13

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command
- When copy/pasting commands that start with `cat << "EOF"`, select all lines at once (from `cat << "EOF"` to `EOF` inclusively) as they are part of the same (single) command

## Guide

### Step 1: create SSH key pair

For increased security, protect private key using strong passphrase.

When asked for file in which to save key, enter `vpn-server`.

Use `vpn-server.pub` public key when setting up server.

```console
$ mkdir -p ~/.ssh

$ cd ~/.ssh

$ ssh-keygen -t rsa -C "vpn-server"
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/sunknudsen/.ssh/id_rsa): vpn-server
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in vpn-server.
Your public key has been saved in vpn-server.pub.
The key fingerprint is:
SHA256:4On7WymZIcM5p8SbsybwJpaFIUrnTUMf/1fdAhI1WPY vpn-server
The key's randomart image is:
+---[RSA 3072]----+
|          .==    |
|     . .  o..o   |
|    . o o  . .E o|
|.... * = .    ..o|
|o.ooo % S .   .. |
|. o..+ O + o .   |
|   =  * + o .    |
|  + + .+ o       |
| . o oo.o.       |
+----[SHA256]-----+

$ cat vpn-server.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCu4k9OcJlatGgUoo41m18Hekv+nSHq1w7qcuAuOZWLI8y5aYkLzyEgyp7EibB0rcmwiZfwx/RDb5zAvlr9KGsOWOYJ/gRIf4AwK1PdBPDo8jaa02J/H585NHV7T7XJ7Ycl/LeJh+oDXGs4OOspiFM/7NuleqCA0sSuJEnnuuTZsIDAlJwtWIJTM8lg4nWCQx2xAGkRyx4eNHE2vmlg+xHu3PbHg9kpSIaBWpx0WsysypyaB77+pkid6kYzxPXexoxFm4FnkoY7PZGb97wl4FwW1EK/yo9rnwbtEq5ny96JEHqeJdxeBGHYrsAoRro4jPWYXvdXZV2s27NYC6S3yHsJdaLfyfJXyTaygOyyaf39GcwqfJZpmVYwVyfZ2Go6ec9R/dFbKEA4Ue7aeCkDskSTiMuUZjYjfhezpa4Y0Jiy+lDZFVSv3tsBYu7Nxq0erZ2ygRJAXUMvvyFICJQGUhblRGXAOwYUt72CSUM0ZMsr84aOWsyzRwVQXzxETuDgnXk= vpn-server
```

### Step 2: log in to server as root

Replace `185.193.126.203` with IP of server.

```shell
ssh root@185.193.126.203 -i ~/.ssh/vpn-server
```

### Step 3: create `vpn-server-admin` user

When asked for password, use output from `openssl rand -base64 24` (and store password in password manager). All other fields are optional, press <kbd>enter</kbd> to skip them and then press <kbd>Y</kbd>.

```console
$ adduser vpn-server-admin
Adding user `vpn-server-admin' ...
Adding new group `vpn-server-admin' (1000) ...
Adding new user `vpn-server-admin' (1000) with group `vpn-server-admin' ...
Creating home directory `/home/vpn-server-admin' ...
Copying files from `/etc/skel' ...
New password:
Retype new password:
passwd: password updated successfully
Changing the user information for vpn-server-admin
Enter the new value, or press ENTER for the default
	Full Name []:
	Room Number []:
	Work Phone []:
	Home Phone []:
	Other []:
Is the information correct? [Y/n] Y
```

### Step 4: copy root’s `authorized_keys` file to vpn-server-admin’s home folder

```shell
mkdir /home/vpn-server-admin/.ssh
cp /root/.ssh/authorized_keys /home/vpn-server-admin/.ssh/authorized_keys
chown -R vpn-server-admin:vpn-server-admin /home/vpn-server-admin/.ssh
```

### Step 5: set root password

When asked for password, use output from `openssl rand -base64 24` (and store password in password manager).

```shell
passwd
```

### Step 6: log out

```shell
exit
```

### Step 7: log in as `vpn-server-admin`

Replace `185.193.126.203` with IP of server.

```shell
ssh vpn-server-admin@185.193.126.203 -i ~/.ssh/vpn-server
```

### Step 8: switch to root

When asked, enter root password.

```shell
su -
```

### Step 9: update SSH config to disable root login and password authentication and restart SSH

```shell
sed -i -E 's/(#)?PermitRootLogin (prohibit-password|yes)/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i -E 's/(#)?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh
```

### Step 10: update apt index files and upgrade packages

#### Update apt index files

```shell
apt update
```

#### Upgrade packages

```shell
apt upgrade -y
```

### Step 11: install and configure Vim

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

### Step 12: set timezone (the following is for Montreal time)

See https://en.wikipedia.org/wiki/List_of_tz_database_time_zones for available timezones.

```shell
timedatectl set-timezone America/Montreal
```

### Step 13: detect network interface and save to environment variables

```console
$ ip -4 route | grep "default" | awk '{print "STRONGSWAN_INTERFACE="$5}' | tee -a ~/.bashrc
STRONGSWAN_INTERFACE=eth0

$ source ~/.bashrc
```

### Step 14: install cURL and Python, generate random IPv6 ULA and save to environment variables

#### Install cURL and Python

```shell
apt install -y curl python
```

#### Generate random IPv6 ULA and save to environment variables

Shout out to [Andrew Ho](https://gist.github.com/andrewlkho/31341da4f5953b8d977aab368e6280a8) for `ulagen.py`.

The following commands downloads and runs [ulagen.py](./ulagen.py) (advanced users may wish to download [ulagen.py.sig](./ulagen.py.sig) and verify signature using my [PGP public key](https://sunknudsen.com/sunknudsen.asc) before running script).

```console
$ curl -s https://sunknudsen.com/static/media/privacy-guides/how-to-self-host-a-hardened-strongswan-ikev2-ipsec-vpn-server-for-ios-and-macos/ulagen.py | python | grep "First subnet" | awk '{print "STRONGSWAN_IPV6_ULA="$3}' | tee -a ~/.bashrc
STRONGSWAN_IPV6_ULA=fdcb:f7a1:38ec::/64

$ source ~/.bashrc
```

### Step 15: install iptables-persistent

When asked to save current IPv4 or IPv6 rules, answer `Yes`.

```shell
apt install -y iptables-persistent
```

### Step 16: configure iptables

```shell
iptables -N SSH_BRUTE_FORCE_MITIGATION
iptables -A SSH_BRUTE_FORCE_MITIGATION -m recent --name SSH --set
iptables -A SSH_BRUTE_FORCE_MITIGATION -m recent --name SSH --update --seconds 300 --hitcount 10 -m limit --limit 1/second --limit-burst 100 -j LOG --log-prefix "iptables[ssh-brute-force-mitigation]: "
iptables -A SSH_BRUTE_FORCE_MITIGATION -m recent --name SSH --update --seconds 300 --hitcount 10 -j DROP
iptables -A SSH_BRUTE_FORCE_MITIGATION -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 22 --syn -m conntrack --ctstate NEW -j SSH_BRUTE_FORCE_MITIGATION
iptables -A INPUT -p udp --dport 500 -j ACCEPT
iptables -A INPUT -p udp --dport 4500 -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 10.0.2.0/24 -m policy --dir in --pol ipsec --proto esp -j ACCEPT
iptables -A FORWARD -d 10.0.2.0/24 -m policy --dir out --pol ipsec --proto esp -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 123 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -o $STRONGSWAN_INTERFACE -m policy --pol ipsec --dir out -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -o $STRONGSWAN_INTERFACE -j MASQUERADE
iptables -t mangle -A FORWARD -m policy --pol ipsec --dir in -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1280
iptables -t mangle -A FORWARD -m policy --pol ipsec --dir out -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1280
iptables -P FORWARD DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP
```

If the server is IPv4-only, run:

```shell
ip6tables -P FORWARD DROP
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
```

If the server is dual stack (IPv4 + IPv6) run:

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
ip6tables -A INPUT -p udp --dport 500 -j ACCEPT
ip6tables -A INPUT -p udp --dport 4500 -j ACCEPT
ip6tables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
ip6tables -A FORWARD -s $STRONGSWAN_IPV6_ULA -m policy --dir in --pol ipsec --proto esp -j ACCEPT
ip6tables -A FORWARD -d $STRONGSWAN_IPV6_ULA -m policy --dir out --pol ipsec --proto esp -j ACCEPT
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
ip6tables -t nat -A POSTROUTING -s $STRONGSWAN_IPV6_ULA -o $STRONGSWAN_INTERFACE -m policy --pol ipsec --dir out -j ACCEPT
ip6tables -t nat -A POSTROUTING -s $STRONGSWAN_IPV6_ULA -o $STRONGSWAN_INTERFACE -j MASQUERADE
ip6tables -t mangle -A FORWARD -m policy --pol ipsec --dir in -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1280
ip6tables -t mangle -A FORWARD -m policy --pol ipsec --dir out -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1280
ip6tables -P FORWARD DROP
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
```

### Step 17: log out and log in to confirm iptables didn’t block SSH

#### Log out

```shell
exit
exit
```

#### Log in

Replace `185.193.126.203` with IP of server.

```shell
ssh vpn-server-admin@185.193.126.203 -i ~/.ssh/vpn-server
```

#### Switch to root

When asked, enter root password.

```shell
su -
```

### Step 18: make iptables rules persistent

```shell
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6
```

### Step 19: add and enable dummy network interface

If server is configured to use `/etc/network/interfaces`, run:

```shell
cp /etc/network/interfaces /etc/network/interfaces.backup
cat << "EOF" >> /etc/network/interfaces
auto strongswan0
iface strongswan0 inet static
  address 10.0.2.1/24
  pre-up ip link add strongswan0 type dummy
EOF
ifup strongswan0
```

If server is configured to use systemd-networkd, run:

```shell
cat << "EOF" >> /etc/systemd/network/10-strongswan0.netdev
[NetDev]
Name=strongswan0
Kind=dummy
EOF
cat << "EOF" >> /etc/systemd/network/20-strongswan0.network
[Match]
Name=strongswan0

[Network]
Address=10.0.2.1/24
EOF
systemctl restart systemd-networkd
```

### Step 20: install, configure and restart dnsmasq

#### Install dnsmasq

Please ignore systemd port conflict error (if present).

```shell
apt install -y dnsmasq
```

#### Configure dnsmasq

```shell
cat << "EOF" > /etc/dnsmasq.d/01-dhcp-strongswan.conf
interface=strongswan0
dhcp-range=10.0.2.10,10.0.2.254,255.255.255.0
port=0
EOF
```

#### Restart dnsmasq

```shell
systemctl restart dnsmasq
```

### Step 21: install strongSwan

If you are shown an "Old runlevel management superseded" warning, answer `Ok`.

```shell
apt install -y strongswan libcharon-extra-plugins
```

### Step 22: configure strongSwan

#### Find server’s DNS nameserver(s)

Depending on the server’s configuration, DNS nameserver(s) can be found using one of the following commands (ignore nameservers starting with `127`).

Fist, run:

```console
$ cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}'
93.95.224.28
93.95.224.29
```

If that doesn’t output valid nameserver(s), run:

```console
$ cat /etc/network/interfaces | grep "dns-nameservers" | awk '{$1="";$0=$0;} NF=NF'
93.95.224.28 93.95.224.29
```

If that doesn’t output valid nameserver(s), run:

```console
$ systemd-resolve --status | grep "DNS Servers" | awk '{print $3}'
95.215.19.53
```

#### Set DNS nameserver(s)

Replace `95.215.19.53` with server’s DNS nameserver(s).

Separate nameservers using commas with no leading spaces (example: `93.95.224.28,93.95.224.29`).

```shell
STRONGSWAN_DNS_NAMESERVERS=95.215.19.53
```

#### Backup and override `/etc/ipsec.conf`

```shell
cp /etc/ipsec.conf /etc/ipsec.conf.backup
```

If the server is IPv4-only, run:

```shell
cat << EOF > /etc/ipsec.conf
config setup
  charondebug="ike 1, knl 1, cfg 1"

conn ikev2
  auto=add
  compress=no
  type=tunnel
  keyexchange=ikev2
  fragmentation=yes
  forceencaps=yes
  ike=aes256gcm16-prfsha512-ecp384!
  esp=aes256gcm16-ecp384!
  dpdaction=clear
  dpddelay=300s
  rekey=no
  left=%any
  leftid=vpn-server.com
  leftcert=server.crt
  leftsendcert=always
  leftsubnet=0.0.0.0/0
  right=%any
  rightid=%any
  rightauth=eap-tls
  rightdns=$STRONGSWAN_DNS_NAMESERVERS
  rightsourceip=%dhcp
  rightsendcert=never
  eap_identity=%identity
EOF
```

If the server is dual stack (IPv4 + IPv6) run:

```shell
cat << EOF > /etc/ipsec.conf
config setup
  charondebug="ike 1, knl 1, cfg 1"

conn ikev2
  auto=add
  compress=no
  type=tunnel
  keyexchange=ikev2
  fragmentation=yes
  forceencaps=yes
  ike=aes256gcm16-prfsha512-ecp384!
  esp=aes256gcm16-ecp384!
  dpdaction=clear
  dpddelay=300s
  rekey=no
  left=%any
  leftid=vpn-server.com
  leftcert=server.crt
  leftsendcert=always
  leftsubnet=0.0.0.0/0,::/0
  right=%any
  rightid=%any
  rightauth=eap-tls
  rightdns=$STRONGSWAN_DNS_NAMESERVERS
  rightsourceip=%dhcp,$STRONGSWAN_IPV6_ULA
  rightsendcert=never
  eap_identity=%identity
EOF
```

#### Backup and override `/etc/ipsec.secrets`

```shell
cp /etc/ipsec.secrets /etc/ipsec.secrets.backup
cat << "EOF" > /etc/ipsec.secrets
: RSA server.key
EOF
```

#### Backup and override `/etc/strongswan.d/charon-logging.conf`

```shell
cp /etc/strongswan.d/charon-logging.conf /etc/strongswan.d/charon-logging.conf.backup
cat << "EOF" > /etc/strongswan.d/charon-logging.conf
charon {
    filelog {
        charon {
            default = 1
        }
    }
    syslog {
        auth {
            default = 1
        }
    }
}
EOF
```

#### Backup and override `/etc/strongswan.d/charon/dhcp.conf`

```shell
cp /etc/strongswan.d/charon/dhcp.conf /etc/strongswan.d/charon/dhcp.conf.backup
cat << "EOF" > /etc/strongswan.d/charon/dhcp.conf
dhcp {
    force_server_address = yes
    identity_lease = yes
    interface = strongswan0
    load = yes
    server = 10.0.2.1
}
EOF
```

#### Disable unused plugins

```shell
cd /etc/strongswan.d/charon
sed -i 's/load = yes/load = no/' ./*.conf
sed -i 's/load = no/load = yes/' ./eap-tls.conf ./aes.conf ./dhcp.conf ./farp.conf ./gcm.conf ./hmac.conf ./kernel-netlink.conf ./nonce.conf ./openssl.conf ./pem.conf ./pgp.conf ./pkcs12.conf ./pkcs7.conf ./pkcs8.conf ./pubkey.conf ./random.conf ./revocation.conf ./sha2.conf ./socket-default.conf ./stroke.conf ./x509.conf
cd
```

#### Backup and edit `/lib/systemd/system/strongswan.service`

```shell
cp /lib/systemd/system/strongswan.service /lib/systemd/system/strongswan.service.backup
sed -i 's/After=network-online.target/After=dnsmasq.service/' /lib/systemd/system/strongswan.service
systemctl daemon-reload
```

### Step 23: create `strongswan-certs` folder

> For security reasons, steps 23 to 27 are done on Mac vs server.

> Store `strongswan-certs` folder in a safe place if you wish to issue additional certificates in the future.

```shell
mkdir ~/Desktop/strongswan-certs
cd ~/Desktop/strongswan-certs
```

### Step 24: create OpenSSL config file

#### Set client common name

Each client is configured using a unique common name ending with `@vpn-server.com`.

```shell
STRONGSWAN_CLIENT_COMMON_NAME=john@vpn-server.com
```

#### Create OpenSSL config file

```shell
cat << EOF > openssl.cnf
[ req ]
distinguished_name = req_distinguished_name
attributes = req_attributes
[ req_distinguished_name ]
countryName = Country Name (2 letter code)
countryName_min = 2
countryName_max = 2
countryName_default = US
0.organizationName = Organization Name (eg, company)
0.organizationName_default = Self-hosted strongSwan VPN
commonName = Common Name (eg, fully qualified host name)
commonName_max = 64
[ req_attributes ]
challengePassword = A challenge password
challengePassword_min = 4
challengePassword_max = 20
[ ca ]
subjectKeyIdentifier = hash
basicConstraints = critical, CA:true
keyUsage = critical, cRLSign, keyCertSign
[ server ]
authorityKeyIdentifier = keyid
subjectAltName = DNS:vpn-server.com
extendedKeyUsage = serverAuth, 1.3.6.1.5.5.8.2.2
[ client ]
authorityKeyIdentifier = keyid
subjectAltName = email:$STRONGSWAN_CLIENT_COMMON_NAME
extendedKeyUsage = serverAuth, 1.3.6.1.5.5.8.2.2
EOF
```

### Step 25: generate certificate authority cert

```console
$ openssl genrsa -out ca.key 4096
Generating RSA private key, 4096 bit long modulus
......................................++
........................................................................................................................................................................................................................................................................................++
e is 65537 (0x10001)

$ openssl req -x509 -new -nodes -config openssl.cnf -extensions ca -key ca.key -subj "/C=US/O=Self-hosted strongSwan VPN/CN=vpn-server.com" -days 3650 -out ca.crt
```

### Step 26: generate server cert

```console
$ openssl genrsa -out server.key 4096
Generating RSA private key, 4096 bit long modulus
.................................................................................................................................................................................................................................................++
................................................................................++
e is 65537 (0x10001)

$ openssl req -new -config openssl.cnf -extensions server -key server.key -subj "/C=US/O=Self-hosted strongSwan VPN/CN=vpn-server.com" -out server.csr

$ openssl x509 -req -extfile openssl.cnf -extensions server -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 3650 -out server.crt
Signature ok
subject=/C=US/O=Self-hosted strongSwan VPN/CN=vpn-server.com
Getting CA Private Key
```

### Step 27: generate client cert

When asked for export password, use output from `openssl rand -base64 24` (and store password in password manager).

```console
$ openssl genrsa -out john.key 4096
Generating RSA private key, 4096 bit long modulus
.........++
............................................................................++
e is 65537 (0x10001)

$ openssl req -new -config openssl.cnf -extensions client -key john.key -subj "/C=US/O=Self-hosted strongSwan VPN/CN=$STRONGSWAN_CLIENT_COMMON_NAME" -out john.csr

$ openssl x509 -req -extfile openssl.cnf -extensions client -in john.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 3650 -out john.crt
Signature ok
subject=/C=US/O=Self-hosted strongSwan VPN/CN=john@vpn-server.com
Getting CA Private Key

$ openssl pkcs12 -in john.crt -inkey john.key -certfile ca.crt -export -out john.p12
Enter Export Password:
Verifying - Enter Export Password:
```

### Step 28: copy/paste the content of `ca.crt`, `server.key` and `server.crt` to server and make private key root-only.

On Mac: run `cat ca.crt`

On server: run `vi /etc/ipsec.d/cacerts/ca.crt`, press <kbd>i</kbd>, paste output from previous step in window, press <kbd>esc</kbd> and press <kbd>shift+z+z</kbd>

On Mac: run `cat server.key`

On server: run `vi /etc/ipsec.d/private/server.key`, press <kbd>i</kbd>, paste output from previous step in window, press <kbd>esc</kbd> and press <kbd>shift+z+z</kbd>

On Mac: run `cat server.crt`

On server: run `vi /etc/ipsec.d/certs/server.crt`, press <kbd>i</kbd>, paste output from previous step in window, press <kbd>esc</kbd> and press <kbd>shift+z+z</kbd>

On server: run `chmod -R 600 /etc/ipsec.d/private`

### Step 29: restart strongSwan

```shell
systemctl restart strongswan
```

### Step 30: configure sysctl

#### Backup and override `/etc/sysctl.conf`

```shell
cp /etc/sysctl.conf /etc/sysctl.conf.backup
sed -i -E 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sed -i -E 's/#net.ipv4.conf.all.accept_redirects = 0/net.ipv4.conf.all.accept_redirects = 0/' /etc/sysctl.conf
sed -i -E 's/#net.ipv4.conf.all.send_redirects = 0/net.ipv4.conf.all.send_redirects = 0/' /etc/sysctl.conf
```

If the server is IPv4-only, run:

```shell
cat << "EOF" >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
```

If the server is dual stack (IPv4 + IPv6) rune:

```shell
sed -i -E 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/' /etc/sysctl.conf
```

#### Reload sysctl

```shell
sysctl -p
```

### Step 31: create VPN profile for iOS and macOS using [Apple Configurator 2](https://support.apple.com/apple-configurator)

> When configuring strongSwan using certs and dnsmasq, two devices cannot use the same provisioning profile simultaneously.

Open "Apple Configurator 2", then click "File", then "New Profile".

In "General", enter "Self-hosted strongSwan VPN" in "Name".

![apple-configurator-general](apple-configurator-general.png?shadow=1)

In "Certificates", click "Configure" and select "ca.crt". Then click "+" and select "john.p12". The password is the one from [step 28](#step-28-generate-client-cert).

![apple-configurator-certificates](apple-configurator-certificates.png?shadow=1)

In "VPN", click "Configure" and enter the settings from the following screenshot (replace `185.193.126.203` with IP of server).

The "Child SA Params" are the same as "IKE SA Params".

![apple-configurator-vpn](apple-configurator-vpn.png?shadow=1)

Finally, click "File", then "Save", and save file as "john.mobileconfig".

### Step 32: add VPN profile to iPhone using Apple Configurator 2

Unlock iPhone, connect it to Mac using USB cable and open Apple Configurator 2.

In "All Devices", double-click on iPhone, then "Add", and finally "Profiles".

Select "john.mobileconfig" and follow instructions.

On iPhone, open "Settings", then "Profile Downloaded" and tap "Install"

### Step 33: add VPN profile to Mac

This step is super simple, simply double-click "john.mobileconfig" and follow instructions.

### Step 34: connect to VPN on iPhone or Mac

On iPhone, open "Settings", then enable "VPN".

On Mac, open "System Preferences", click "Network", then "Self-hosted strongSwan VPN" and finally "Connect" and enable "Show VPN status in menu bar".

### Step 35: test for leaks

Open Firefox and go to https://ipleak.net/.

Make sure listed IPv4, IPv6 (if server is dual stack) and DNS servers do not match the ones supplied by client ISP.

### Step 36: create additional provisioning profiles

Repeat steps [24](#step-24-create-openssl-config-file), [27](#step-27-generate-client-cert) and [31](#step-31-create-vpn-profile-for-ios-and-macos-using).
