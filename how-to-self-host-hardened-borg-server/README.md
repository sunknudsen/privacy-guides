<!--
Title: How to self-host hardened Borg server
Description: Learn how to self-host hardened Borg server.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2020-11-27T17:49:18.440Z
Listed: true
-->

# How to self-host hardened Borg server

[![How to self-host hardened Borg server - YouTube](how-to-self-host-hardened-borg-server.png)](https://www.youtube.com/watch?v=rzEaxL6F2Eg "How to self-host hardened Borg server - YouTube")

## Requirements

- [Hardened Debian server](../how-to-configure-hardened-debian-server) 📦 or [hardened Raspberry Pi OS server](../how-to-configure-hardened-raspberry-pi-os-server) 📦
- Linux or macOS computer

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command
- When copy/pasting commands that start with `cat << "EOF"`, select all lines at once (from `cat << "EOF"` to `EOF` inclusively) as they are part of the same (single) command

## Setup guide

### Step 1: create `borg` SSH key pair (on computer)

When asked for file in which to save key, enter `borg`.

When asked for passphrase, use output from `openssl rand -base64 24` (and store passphrase in password manager).

```console
$ mkdir -p ~/.ssh

$ cd ~/.ssh

$ ssh-keygen -t rsa -C "borg"
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/sunknudsen/.ssh/id_rsa): borg
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in borg.
Your public key has been saved in borg.pub.
The key fingerprint is:
SHA256:b4YxePgBjP9hB/wPFz7MkzM5fDYEBtbtOBd7kxRTicY borg
The key's randomart image is:
+---[RSA 3072]----+
|          oo+..o=|
|     o . . ..Eoo.|
|    . o o   oooo.|
|     . + o =o=+o.|
|      + S + #o+..|
|       = O + O . |
|        + + .    |
|         o       |
|                 |
+----[SHA256]-----+

$ cat borg.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClMqEv1xTTWrz9cRGFsjtQ5ieK7sMs2eUMyROg1emhblUmGd6cMMfQDFDlwXUXk7ZPDHIkN3k9recff1oa3tvW+9D2oqGSyG0WOXqbZNHXZUSEhb9giOlVij0kOjfVbMR37zMZn+e6cVzq75Kn5B/ZSm9pfpWI5p4sHEn9S8TvoSgvCCu67bWc3UHHedd9dK5kJUPHNHvZUf+ebNo69iZuKE9HSP7eifGx5DszkU5cs6DPivAvRGgGer7Um2piQ+T7q+XcKo0JcaXVaObDZSGTZwiF8xAFDF1bfCl9jna26ZqqPKHdJJTEl8gaj9MQH6vlsAZ40xeFyCxiG0AhVpQ6SeeIN2qkf6k7EDyUQNcCmwY23THhFhEjfjuq6mbsuCK52tUx7bDMF8wed0lQ5k7OLuQuwyxDUinz3aBwboUQxxHfzImgKXzIrZ0hPge3fIgtFUBiUwFUv5xnTzBIStP5BFf5Ca5oxRq4rJDORnD0wMuMTWSyGZFVU5iEVml0Jhk= borg
```

### Step 2: create `borg-append-only` SSH key pair (on computer)

When asked for file in which to save key, enter `borg-append-only`.

When asked for passphrase, leave field empty for no passphrase.

```console
$ ssh-keygen -t rsa -C "borg-append-only"
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/sunknudsen/.ssh/id_rsa): borg-append-only
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in borg-append-only.
Your public key has been saved in borg-append-only.pub.
The key fingerprint is:
SHA256:xR8BvPMujEM955VubA/TWVlqt/Nt2INNX4UIw3wtssw borg-append-only
The key's randomart image is:
+---[RSA 3072]----+
|         +....   |
|         .B o..  |
|         ooB.o ..|
|         .E.....+|
|        S. o. oo+|
|        . o o.o+=|
|       . o = +**+|
|        o o o.*=B|
|         . . o o=|
+----[SHA256]-----+

$ cat borg-append-only.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDsEfUNEZToWjefcGr8Dy/d+6ILuklWjC18E3ziaCZPNzKZAMfZTXm0CqKYgwRH5UXgYz//3gLPLNLtlHNeluVXSzLO1pxc+2Au19JOfzgcy86A3y4Gx8lFh80VyHhm33LjHsKsgacF2C0tKDBaJ/WqwDpX0m+E1WHCF0xZ7QdgGEoqj31yJ34WCeOXOro1yJfrV98iVWKuokCMHboaQoXTNu4+AMzGw/1MPUgmkT1nGnBpN5lP1v+kwAXAemC+A+Aw8gLf3pq84uAOhiTficH57PiyasJtwll5loDinkhnBtYhPHO9qN+M+n0by3rmIhsEIukdpwiI5Qm4LNTm6i53NiX1rfN2ln4SvqwVG7mmkqP9PbJXsgtD6mNjXOhncHvHeTbEb8IAHg28hGpq1rn8284+2jvviw9FMAzIgkeLRmAHz+XVAOmZDkn0128H4bYXAOeLISxTbgY1WAWzGnW+kCYbmQV3e8wAyOrp8mfZ1LgMvfc2/o0D9828Zy5UP4c= borg-append-only
```

### Step 3: generate SSH authorized keys heredoc (on computer)

#### Set temporary environment variable

```shell
BORG_STORAGE_QUOTA="10G"
```

#### Generate heredoc (the output of following command will be used at [step 8](#create-homeborgsshauthorized_keys-using-heredoc-generated-at-step-2))

```shell
cat << EOF
cat << _EOF > /home/borg/.ssh/authorized_keys
command="borg serve --restrict-to-repository /home/borg/backup --storage-quota $BORG_STORAGE_QUOTA",restrict $(cat ~/.ssh/borg.pub)
command="borg serve --append-only --restrict-to-repository /home/borg/backup --storage-quota $BORG_STORAGE_QUOTA",restrict $(cat ~/.ssh/borg-append-only.pub)
_EOF
EOF
```

### Step 4: log in to server

Replace `server-admin@185.112.147.115` with SSH destination of server and `~/.ssh/server` with path to associated private key.

```shell
ssh server-admin@185.112.147.115 -i ~/.ssh/server
```

### Step 5: switch to root

When asked, enter root password.

```shell
su -
```

### Step 6: create `borg` user

When asked for password, use output from `openssl rand -base64 24` (and store password in password manager).

All other fields are optional, press <kbd>enter</kbd> to skip them and then press <kbd>Y</kbd>.

```console
$ adduser borg
Adding user `borg' ...
Adding new group `borg' (1000) ...
Adding new user `borg' (1000) with group `borg' ...
Creating home directory `/home/borg' ...
Copying files from `/etc/skel' ...
New password:
Retype new password:
passwd: password updated successfully
Changing the user information for borg
Enter the new value, or press ENTER for the default
	Full Name []:
	Room Number []:
	Work Phone []:
	Home Phone []:
	Other []:
Is the information correct? [Y/n] Y
```

### Step 7: update APT index

```shell
apt update
```

### Step 8: install [Borg](https://github.com/borgbackup/borg)

```shell
apt install -y borgbackup
```

### Step 9: configure borg SSH authorized keys

#### Create `.ssh` folder

```shell
mkdir -p /home/borg/.ssh
```

#### Create `/home/borg/.ssh/authorized_keys` using heredoc generated at [step 2](#generate-heredoc-the-output-of-following-command-will-be-used-at-step-8)

```shell
cat << _EOF > /home/borg/.ssh/authorized_keys
command="borg serve --restrict-to-repository /home/borg/backup --storage-quota 10G",restrict ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClMqEv1xTTWrz9cRGFsjtQ5ieK7sMs2eUMyROg1emhblUmGd6cMMfQDFDlwXUXk7ZPDHIkN3k9recff1oa3tvW+9D2oqGSyG0WOXqbZNHXZUSEhb9giOlVij0kOjfVbMR37zMZn+e6cVzq75Kn5B/ZSm9pfpWI5p4sHEn9S8TvoSgvCCu67bWc3UHHedd9dK5kJUPHNHvZUf+ebNo69iZuKE9HSP7eifGx5DszkU5cs6DPivAvRGgGer7Um2piQ+T7q+XcKo0JcaXVaObDZSGTZwiF8xAFDF1bfCl9jna26ZqqPKHdJJTEl8gaj9MQH6vlsAZ40xeFyCxiG0AhVpQ6SeeIN2qkf6k7EDyUQNcCmwY23THhFhEjfjuq6mbsuCK52tUx7bDMF8wed0lQ5k7OLuQuwyxDUinz3aBwboUQxxHfzImgKXzIrZ0hPge3fIgtFUBiUwFUv5xnTzBIStP5BFf5Ca5oxRq4rJDORnD0wMuMTWSyGZFVU5iEVml0Jhk= borg
command="borg serve --append-only --restrict-to-repository /home/borg/backup --storage-quota 10G",restrict ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDsEfUNEZToWjefcGr8Dy/d+6ILuklWjC18E3ziaCZPNzKZAMfZTXm0CqKYgwRH5UXgYz//3gLPLNLtlHNeluVXSzLO1pxc+2Au19JOfzgcy86A3y4Gx8lFh80VyHhm33LjHsKsgacF2C0tKDBaJ/WqwDpX0m+E1WHCF0xZ7QdgGEoqj31yJ34WCeOXOro1yJfrV98iVWKuokCMHboaQoXTNu4+AMzGw/1MPUgmkT1nGnBpN5lP1v+kwAXAemC+A+Aw8gLf3pq84uAOhiTficH57PiyasJtwll5loDinkhnBtYhPHO9qN+M+n0by3rmIhsEIukdpwiI5Qm4LNTm6i53NiX1rfN2ln4SvqwVG7mmkqP9PbJXsgtD6mNjXOhncHvHeTbEb8IAHg28hGpq1rn8284+2jvviw9FMAzIgkeLRmAHz+XVAOmZDkn0128H4bYXAOeLISxTbgY1WAWzGnW+kCYbmQV3e8wAyOrp8mfZ1LgMvfc2/o0D9828Zy5UP4c= borg-append-only
_EOF
```

#### Change ownership of `/home/borg/.ssh`

```
chown -R borg:borg /home/borg/.ssh
```

👍
