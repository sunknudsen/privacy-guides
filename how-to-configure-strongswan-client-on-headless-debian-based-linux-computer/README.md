<!--
Title: How to configure strongSwan client on headless Debian-based Linux computer
Description: Learn how to configure strongSwan client on headless Debian-based Linux computer.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2020-12-06T12:41:40.806Z
Listed: true
-->

# How to configure strongSwan client on headless Debian-based Linux computer

## Requirements

- [Self-hosted hardened strongSwan IKEv2/IPsec VPN server](../how-to-self-host-hardened-strongswan-ikev2-ipsec-vpn-server-for-ios-and-macos) 📦
- Linux or macOS computer (referred to as “certificate authority computer”)
- Debian-based Linux computer (referred to as “client computer”)

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command
- When copy/pasting commands that start with `cat << "EOF"`, select all lines at once (from `cat << "EOF"` to `EOF` inclusively) as they are part of the same (single) command

## Guide

### Step 1: create client certs using certificate authority from [How to self-host hardened strongSwan IKEv2/IPsec VPN server for iOS and macOS](../how-to-self-host-hardened-strongswan-ikev2-ipsec-vpn-server-for-ios-and-macos) (using certificate authority computer).

#### Navigate to `strongswan-certs` folder

```shell
cd ~/Desktop/strongswan-certs
```

#### Set client common name

```shell
STRONGSWAN_CLIENT_COMMON_NAME=bob@vpn-server.com
```

#### Update OpenSSL config file

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

#### Generate client cert

```
$ openssl genrsa -out bob.key 4096
Generating RSA private key, 4096 bit long modulus
..............................++
....................................................................................................++
e is 65537 (0x10001)

$ openssl req -new -config openssl.cnf -extensions client -key bob.key -subj "/C=US/O=Self-hosted strongSwan VPN/CN=$STRONGSWAN_CLIENT_COMMON_NAME" -out bob.csr

$ openssl x509 -req -extfile openssl.cnf -extensions client -in bob.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 3650 -out bob.crt
Signature ok
subject=/C=US/O=Self-hosted strongSwan VPN/CN=bob@vpn-server.com
Getting CA Private Key
```

### Step 2: log in to client computer

Replace `pi@10.0.1.69` with SSH destination of client computer and `~/.ssh/pi` with path to associated private key.

```shell
ssh pi@10.0.1.69 -i ~/.ssh/pi
```

### Step 3: switch to root

```shell
su -
```

### Step 4: configure iptables

> Heads-up: input rules are likely already configured (run `iptables-save` and `ip6tables-save` to check).

#### Configure IPv4 rules

```shell
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --dport 500 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 4500 -m state --state NEW -j ACCEPT
```

#### Configure IPv6 rules (if network is dual stack)

```shell
ip6tables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
ip6tables -A OUTPUT -p udp --dport 500 -m state --state NEW -j ACCEPT
ip6tables -A OUTPUT -p udp --dport 4500 -m state --state NEW -j ACCEPT
```

#### Make iptables rules persistent

```shell
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6
```

### Step 5: update APT index

```shell
apt update
```

### Step 6: install strongSwan

If you are shown an “Old runlevel management superseded” warning, answer “Ok”.

```shell
apt install -y strongswan libcharon-extra-plugins
```

### Step 7: configure strongSwan

#### Backup and override `/etc/ipsec.conf`

Replace `185.193.126.203` with IP of server.

```shell
cp /etc/ipsec.conf /etc/ipsec.conf.backup
cat << EOF > /etc/ipsec.conf
conn ikev2
  auto=start
  ike=aes256gcm16-prfsha512-ecp384!
  esp=aes256gcm16-ecp384!
  dpdaction=restart
  closeaction=restart
  keyingtries=%forever
  leftid=bob@vpn-server.com
  leftsourceip=%config
  leftauth=eap-tls
  leftcert=bob.crt
  right=185.193.126.203
  rightid=vpn-server.com
  rightsubnet=0.0.0.0/0
  rightauth=pubkey
EOF
```

#### Backup and override `/etc/ipsec.secrets`

```shell
cp /etc/ipsec.secrets /etc/ipsec.secrets.backup
cat << "EOF" > /etc/ipsec.secrets
: RSA bob.key
EOF
```

#### Disable unused plugins

```shell
cd /etc/strongswan.d/charon
sed -i 's/load = yes/load = no/' ./*.conf
sed -i 's/load = no/load = yes/' ./eap-tls.conf ./aes.conf ./dhcp.conf ./farp.conf ./gcm.conf ./hmac.conf ./kernel-netlink.conf ./nonce.conf ./openssl.conf ./pem.conf ./pgp.conf ./pkcs12.conf ./pkcs7.conf ./pkcs8.conf ./pubkey.conf ./random.conf ./revocation.conf ./sha2.conf ./socket-default.conf ./stroke.conf ./x509.conf
cd -
```

### Step 8: copy/paste content of `ca.crt`, `bob.key` and `bob.crt` to server and make private key root-only.

On certificate authority computer: run `cat ca.crt`

On client computer: run `vi /etc/ipsec.d/cacerts/ca.crt`, press <kbd>i</kbd>, paste output from previous step in window, press <kbd>esc</kbd> and press <kbd>shift+z+z</kbd>

On certificate authority computer: run `cat bob.key`

On client computer: run `vi /etc/ipsec.d/private/bob.key`, press <kbd>i</kbd>, paste output from previous step in window, press <kbd>esc</kbd> and press <kbd>shift+z+z</kbd>

On certificate authority computer: run `cat bob.crt`

On client computer: run `vi /etc/ipsec.d/certs/bob.crt`, press <kbd>i</kbd>, paste output from previous step in window, press <kbd>esc</kbd> and press <kbd>shift+z+z</kbd>

On client computer: run `chmod -R 600 /etc/ipsec.d/private`

### Step 9: restart strongSwan

```shell
systemctl restart strongswan
```

### Step 10: confirm strongSwan client is connected

```shell
$ ipsec status
Security Associations (1 up, 0 connecting):
       ikev2[1]: ESTABLISHED 3 minutes ago, 10.0.1.69[bob@vpn-server.com]...185.193.126.203[vpn-server.com]
       ikev2{1}:  INSTALLED, TUNNEL, reqid 1, ESP in UDP SPIs: c3fcabed_i c2b0c4cd_o
       ikev2{1}:   10.0.2.199/32 === 0.0.0.0/0
```

ESTABLISHED

👍

> Heads-up: use following steps to assign static IP to strongSwan client

### Step 11: log in to server

Replace `185.193.126.203` with IP of server.

```shell
ssh vpn-server-admin@185.193.126.203 -i ~/.ssh/vpn-server
```

### Step 12: switch to root

```shell
su -
```

### Step 13: get virtual MAC address assigned to strongSwan client

> Heads-up: run `ipsec status` as root on headless Debian-based Linux computer to see which IP was assigned to strongSwan client (`10.0.2.199` in the following example).

```shell
$ cat /var/lib/misc/dnsmasq.leases | grep "10.0.2.199" | awk '{print $2}'
7a:a7:3b:4b:77:16
```

### Step 14: assign static IP to strongSwan client

```shell
echo "dhcp-host=7a:a7:3b:4b:77:16,10.0.2.2" >> /etc/dnsmasq.d/01-dhcp-strongswan.conf
```

### Step 15: restart dnsmasq

```shell
systemctl restart dnsmasq
```

### Step 16: log in to client computer

Replace `pi@10.0.1.69` with SSH destination of client computer and `~/.ssh/pi` with path to associated private key.

```shell
ssh pi@10.0.1.69 -i ~/.ssh/pi
```

### Step 17: switch to root

```shell
su -
```

### Step 18: restart strongSwan

```shell
systemctl restart strongswan
```

### Step 19: confirm strongSwan client has IP `10.0.2.2`

```shell
$ ipsec status
Security Associations (1 up, 0 connecting):
       ikev2[1]: ESTABLISHED 3 minutes ago, 10.0.1.69[bob@vpn-server.com]...185.193.126.203[vpn-server.com]
       ikev2{1}:  INSTALLED, TUNNEL, reqid 1, ESP in UDP SPIs: c3fcabed_i c2b0c4cd_o
       ikev2{1}:   10.0.2.5/32 === 0.0.0.0/0
```

10.0.2.2/32

👍
