<!--
Title: How to seed bitcoin-dataset
Description: Learn how to seed bitcoin-dataset.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2022-03-01T17:31:42.392Z
Listed: true
-->

# How to seed bitcoin-dataset

## Requirements

- [Hardened Debian server](../../how-to-configure-hardened-debian-server/README.md) (with at least 1TB of SSD storage and IPv6 disabled)
- Linux or macOS computer

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command
- When copy/pasting commands that start with `cat << "EOF"`, select all lines at once (from `cat << "EOF"` to `EOF` inclusively) as they are part of the same (single) command

## Guide

### Step 1: install dependencies

```console
$ apt update

$ apt upgrade

$ apt install -y curl gnupg transmission-cli transmission-daemon

$ systemctl disable transmission-daemon

$ systemctl stop transmission-daemon
```

### Step 2: increase `rmem_max` and `wmem_max`

```console
$ cat << "EOF" >> /etc/sysctl.conf
net.core.rmem_max = 4194304
net.core.wmem_max = 1048576
EOF

$ sysctl -p
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.core.rmem_max = 4194304
net.core.wmem_max = 1048576
```

### Step 3: configure firewall

> Heads-up: replace `eth0` with network interface (run `ip a` to find interface).

```console
$ NETWORK_INTERFACE=eth0

$ cat << EOF > /etc/nftables.conf
#!/usr/sbin/nft -f

flush ruleset

table ip firewall {
	chain input {
		type filter hook input priority filter; policy drop;
		iif "lo" accept
		iif != "lo" ip daddr 127.0.0.0/8 drop
		iifname "$NETWORK_INTERFACE" tcp dport { 22, 51413 } accept
		ct state established,related accept
	}

	chain forward {
		type filter hook forward priority filter; policy drop;
	}

	chain output {
		type filter hook output priority filter; policy drop;
		oif "lo" accept
		oifname "$NETWORK_INTERFACE" tcp dport { 80, 443, 51413, 57715 } accept
		oifname "$NETWORK_INTERFACE" udp dport { 53, 123 } accept
		ct state established,related accept
	}
}
table ip6 firewall {
	chain input {
		type filter hook input priority filter; policy drop;
	}

	chain forward {
		type filter hook forward priority filter; policy drop;
	}

	chain output {
		type filter hook output priority filter; policy drop;
	}
}
EOF

$ nft -f /etc/nftables.conf
```

### Step 4: configure transmission-daemon

```shell
cat << "EOF" > /etc/transmission-daemon/settings.json
{
  "dht-enabled": false,
  "encryption": 2,
  "message-level": 1,
  "pex-enabled": false,
  "port-forwarding-enabled": true,
  "rpc-authentication-required": false,
  "rpc-enabled": true,
  "utp-enabled": false
}
EOF
```

### Step 5: import Sun’s PGP public key (used to verify downloads below)

```console
$ curl --fail https://sunknudsen.com/sunknudsen.asc | gpg --import
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  2070  100  2070    0     0   3219      0 --:--:-- --:--:-- --:--:--  3214
gpg: key 8C9CA674C47CA060: 1 signature not checked due to a missing key
gpg: /root/.gnupg/trustdb.gpg: trustdb created
gpg: key 8C9CA674C47CA060: public key "Sun Knudsen <hello@sunknudsen.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg: no ultimately trusted keys found
```

imported: 1

👍

### Step 6: verify integrity of Sun’s PGP public key (learn how [here](../how-to-encrypt-sign-and-decrypt-messages-using-gnupg-on-macos#verify-suns-pgp-public-key-using-fingerprint))

```console
$ gpg --fingerprint hello@sunknudsen.com
pub   ed25519 2021-12-28 [C]
      E786 274B C92B 47C2 3C1C  F44B 8C9C A674 C47C A060
uid           [ unknown] Sun Knudsen <hello@sunknudsen.com>
sub   ed25519 2021-12-28 [S] [expires: 2022-12-28]
sub   cv25519 2021-12-28 [E] [expires: 2022-12-28]
sub   ed25519 2021-12-28 [A] [expires: 2022-12-28]
```

Fingerprint matches published fingerprints

👍

### Step 7: download and verify [transmission-daemon.service](./transmission-daemon.service)

```console
$ curl --fail --output /lib/systemd/system/transmission-daemon.service https://raw.githubusercontent.com/sunknudsen/privacy-guides/master/how-to-self-host-hardened-bitcoin-node/transmission-daemon.service
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1598  100  1598    0     0    568      0  0:00:02  0:00:02 --:--:--   568

$ curl --fail --output /lib/systemd/system/transmission-daemon.service.asc https://raw.githubusercontent.com/sunknudsen/privacy-guides/master/how-to-self-host-hardened-bitcoin-node/transmission-daemon.service.asc
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed

$ gpg --verify /lib/systemd/system/transmission-daemon.service.asc
gpg: assuming signed data in '/lib/systemd/system/transmission-daemon.service'
gpg: Signature made Sun 27 Feb 2022 01:47:27 PM EST
gpg:                using EDDSA key 9C7887E1B5FCBCE2DFED0E1C02C43AD072D57783
gpg: Good signature from "Sun Knudsen <hello@sunknudsen.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: E786 274B C92B 47C2 3C1C  F44B 8C9C A674 C47C A060
     Subkey fingerprint: 9C78 87E1 B5FC BCE2 DFED  0E1C 02C4 3AD0 72D5 7783
```

Good signature

👍

### Step 8: download and verify bitcoin-dataset torrent

```console
$ curl --fail --remote-name https://raw.githubusercontent.com/sunknudsen/privacy-guides/master/how-to-self-host-hardened-bitcoin-node/bitcoin-dataset.torrent
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 4271k  100 4271k    0     0  3911k      0  0:00:01  0:00:01 --:--:-- 3911k

$ curl --fail --remote-name https://raw.githubusercontent.com/sunknudsen/privacy-guides/master/how-to-self-host-hardened-bitcoin-node/bitcoin-dataset.torrent.asc
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   228  100   228    0     0    740      0 --:--:-- --:--:-- --:--:--   740

$ gpg --verify bitcoin-dataset.torrent.asc
gpg: assuming signed data in 'bitcoin-dataset.torrent'
gpg: Signature made Tue 01 Mar 2022 10:46:35 AM EST
gpg:                using EDDSA key 9C7887E1B5FCBCE2DFED0E1C02C43AD072D57783
gpg: Good signature from "Sun Knudsen <hello@sunknudsen.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: E786 274B C92B 47C2 3C1C  F44B 8C9C A674 C47C A060
     Subkey fingerprint: 9C78 87E1 B5FC BCE2 DFED  0E1C 02C4 3AD0 72D5 7783
```

Good signature

👍

### Step 9: enable and start transmission-daemon

```console
$ systemctl enable transmission-daemon

$ systemctl start transmission-daemon
```

### Step 10: start bitcoin-dataset torrent

```console
$ transmission-remote --add bitcoin-dataset.torrent --start
```

### Step 11: watch bitcoin-dataset torrent

```console
$ watch transmission-remote --list
Every 2.0s: transmission-remote --list                                           debian: Tue Mar  1 11:56:05 2022

    ID   Done       Have  ETA           Up    Down  Ratio  Status       Name
     1   100%   458.4 GB  Done         0.0     0.0    0.0  Idle         bitcoin-dataset
Sum:            458.4 GB               0.0     0.0
```

100%

👍
