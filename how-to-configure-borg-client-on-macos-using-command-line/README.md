<!--
Title: How to configure Borg client on macOS using command-line
Description: Learn how to configure Borg client on macOS using command-line.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2020-11-27T18:07:56.515Z
Listed: true
-->

# How to configure Borg client on macOS using command-line

## Requirements

- Borg server ([self-hosted](../how-to-self-host-hardened-borg-server) or cloud-based such as [BorgBase](https://www.borgbase.com/) or [rsync.net](https://rsync.net/products/attic.html))
- Computer running macOS Mojave or Catalina

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command
- When copy/pasting commands that start with `cat << "EOF"`, select all lines at once (from `cat << "EOF"` to `EOF` inclusively) as they are part of the same (single) command

## Setup guide

> Heads-up: steps 1 to 4 are only required if using BorgBase or rsync.net (don’t forget to enable 2FA).

### Step 1: create `borg` SSH key pair (if using BorgBase or rsync.net)

When asked for file in which to save key, enter `borg`.

When asked for passphrase, use output from `openssl rand -base64 24` (and store passphrase in password manager).

Use `borg.pub` public key when configuring Borg server.

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

### Step 2: create `borg-append-only` SSH key pair (if using BorgBase or rsync.net)

When asked for file in which to save key, enter `borg-append-only`.

When asked for passphrase, leave field empty for no passphrase (this public key will be used for append-only operations).

Use `borg-append-only.pub` public key when configuring Borg server.

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

### Step 3: configure SSH keys and create repo (if using BorgBase)

#### Configure SSH keys

Go to [SSH Keys](https://www.borgbase.com/account) and add `borg.pub` and `borg-append-only.pub` keys.

![Add SSH key](./borgbase-add-ssh-key.png?shadow=1)

![SSH keys](./borgbase-ssh-keys.png?shadow=1)

#### Create repo

Go to [Repositories](https://www.borgbase.com/account) and add repository.

![Add repository](./borgbase-add-repository.png?shadow=1)

![Repositories](./borgbase-repositories.png?shadow=1)

### Step 4: generate and upload `authorized_keys` file (if using rsync.net)

#### Set temporary environment variable

```shell
BORG_STORAGE_QUOTA="500G"
```

#### Generate `authorized_keys` file

Replace `18434` with rsync.net username.

```shell
cat << EOF > ~/Desktop/authorized_keys
command="borg1 serve --restrict-to-repository /data1/home/18434/backup --storage-quota $BORG_STORAGE_QUOTA",restrict $(cat ~/.ssh/borg.pub)
command="borg1 serve --append-only --restrict-to-repository /data1/home/18434/backup --storage-quota $BORG_STORAGE_QUOTA",restrict $(cat ~/.ssh/borg-append-only.pub)
EOF
```

#### Upload `authorized_keys` file

```shell
scp ~/Desktop/authorized_keys 18434@ch-s011.rsync.net:.ssh/authorized_keys
```

### Step 5: install [Homebrew](https://brew.sh/)

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

### Step 6: disable Homebrew analytics

```shell
brew analytics off
```

### Step 7: install [FUSE for macOS](https://osxfuse.github.io/), [Borg](https://www.borgbackup.org/) and [Borg Wrapper](https://github.com/sunknudsen/borg-wrapper)

> Heads-up: when installing Borg using `brew install borgbackup`, one can no longer run `brew mount` (see [issue](https://github.com/borgbackup/borg/issues/5522)) so I created a [tap](https://github.com/borgbackup/homebrew-tap) that includes a patched version of [borgbackup](https://formulae.brew.sh/formula/borgbackup) called [borgbackup-fuse](https://github.com/borgbackup/homebrew-tap/blob/master/Formula/borgbackup-fuse.rb).

> Heads-up: if `brew install --cask osxfuse` fails, try `brew cask install osxfuse` (see [issue](https://github.com/Homebrew/brew/issues/9382)).

```shell
brew install --cask osxfuse
brew install borgbackup/tap/borgbackup-fuse
brew install --cask sunknudsen/tap/borg-wrapper
```

### Step 8: configure Borg

#### Generate Borg passphrase using `openssl` and add passphrase to “Keychain Access”

```shell
security add-generic-password -D secret -U -a $USER -s borg-passphrase -w $(openssl rand -base64 24)
```

#### Initialize Borg repo

Replace `borg@185.112.147.115:backup` with self-hosted or cloud-based repo.

```console
$ export BORG_PASSCOMMAND="security find-generic-password -a $USER -s borg-passphrase -w"

$ export BORG_RSH="ssh -i ~/.ssh/borg"

$ borg init --encryption=keyfile-blake2 "borg@185.112.147.115:backup"
Enter passphrase for key '/Users/sunknudsen/.ssh/borg':

By default repositories initialized with this version will produce security
errors if written to with an older version (up to and including Borg 1.0.8).

If you want to use these older versions, you can disable the check by running:
borg upgrade --disable-tam ssh://borg@185.112.147.115/./backup

See https://borgbackup.readthedocs.io/en/stable/changes.html#pre-1-0-9-manifest-spoofing-vulnerability for details about the security implications.

IMPORTANT: you will need both KEY AND PASSPHRASE to access this repo!
Use "borg key export" to export the key, optionally in printable format.
Write down the passphrase. Store both at safe place(s).

```

#### Backup `~/.config/borg` and `~/Library/Keychains` folders

> Heads-up: both key (stored in `~/.config/borg`) and passphrase (stored in `~/Library/Keychains`) are required to decrypt backup.

### Step 9: set temporary environment variables

Replace `borg@185.112.147.115:backup` with self-hosted or cloud-based repo and set backup name.

```shell
BORG_REPO="borg@185.112.147.115:backup"
BACKUP_NAME="$USER-macbook-pro"
```

### Step 10: create `/usr/local/bin/borg-backup.sh` script

```shell
cat << EOF > /usr/local/bin/borg-backup.sh
#! /bin/sh

set -e

repo="$BORG_REPO"
prefix="$BACKUP_NAME-"

export BORG_PASSCOMMAND="security find-generic-password -a $USER -s borg-passphrase -w"
export BORG_RSH="ssh -i ~/.ssh/borg-append-only"

borg create \\
  --filter "AME" \\
  --list \\
  --stats \\
  --verbose \\
  "\$repo::\$prefix{now:%F-%H%M%S}" \\
  "/Users/$USER/.ssh" \\
  "/Users/$USER/Library/Keychains"

printf "%s\n" "Done"
EOF
chmod +x /usr/local/bin/borg-backup.sh
```

### Step 11: edit `/usr/local/bin/borg-backup.sh` script

```shell
vi /usr/local/bin/borg-backup.sh
```

### Step 12: create `/usr/local/bin/borg-list.sh` script

```shell
cat << EOF > /usr/local/bin/borg-list.sh
#! /bin/sh

set -e

prefix="$BACKUP_NAME-"
repo="$BORG_REPO"

export BORG_PASSCOMMAND="security find-generic-password -a $USER -s borg-passphrase -w"
export BORG_RSH="ssh -i ~/.ssh/borg-append-only"

borg list --prefix "\$prefix" "\$repo"

printf "%s\n" "Done"
EOF
chmod +x /usr/local/bin/borg-list.sh
```

### Step 13: create `/usr/local/bin/borg-check.sh` script

```shell
cat << EOF > /usr/local/bin/borg-check.sh
#! /bin/sh

set -e

prefix="$BACKUP_NAME-"
repo="$BORG_REPO"

export BORG_PASSCOMMAND="security find-generic-password -a $USER -s borg-passphrase -w"
export BORG_RSH="ssh -i ~/.ssh/borg-append-only"

borg check --prefix "\$prefix" "\$repo"

printf "%s\n" "Done"
EOF
chmod +x /usr/local/bin/borg-check.sh
```

### Step 14: create `/usr/local/bin/borg-restore.sh` script

```shell
cat << EOF > /usr/local/bin/borg-restore.sh
#! /bin/sh

set -e

function umount()
{
  if [ -d "\$mount_point" ]; then
    borg umount \$mount_point
  fi
}

trap umount ERR INT

mount_point="\${TMPDIR}borg"
prefix="$BACKUP_NAME-"
repo="$BORG_REPO"

mkdir -p \$mount_point

export BORG_PASSCOMMAND="security find-generic-password -a $USER -s borg-passphrase -w"
export BORG_RSH="ssh -i ~/.ssh/borg-append-only"

borg mount --prefix "\$prefix" "\$repo" "\$mount_point"

open \$mount_point

printf "Restore data and press enter"

read -r answer

umount

printf "%s\n" "Done"
EOF
chmod +x /usr/local/bin/borg-restore.sh
```

### Step 15: create `/usr/local/bin/borg-prune.sh` script

```shell
cat << EOF > /usr/local/bin/borg-prune.sh
#! /bin/sh

set -e

prefix="$BACKUP_NAME-"
repo="$BORG_REPO"

export BORG_PASSCOMMAND="security find-generic-password -a $USER -s borg-passphrase -w"
export BORG_RSH="ssh -i ~/.ssh/borg"

borg prune --keep-hourly 24 --keep-daily 31 --keep-weekly 52 --keep-monthly -1 --list --prefix "\$prefix" --stats "\$repo"

printf "%s\n" "Done"
EOF
chmod +x /usr/local/bin/borg-prune.sh
```

### Step 16: create `/usr/local/var/log` folder

```shell
mkdir -p /usr/local/var/log
```

### Step 17: run “Borg Wrapper”

```shell
open /Applications/Borg\ Wrapper.app
```

> Heads-up: given “Borg Wrapper” is developed outside the [Apple Developer Program](https://developer.apple.com/programs/), macOS prevents opening the app without explicit user consent (granted by clicking “Open Anyway” in “System Preferences” / “Privacy & Security”).

![Allow app 1](./allow-app-1.png?shadow=1&width=420)

![Allow app 2](./allow-app-2.png?shadow=1&width=668)

![Allow app 3](./allow-app-3.png?shadow=1&width=475)

Backup completed

👍

### Step 18: schedule backup every hour using launchd

```shell
mkdir -p ~/Library/LaunchAgents
cat << EOF > ~/Library/LaunchAgents/local.borg-wrapper.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>Borg Wrapper.app</string>

    <key>ProgramArguments</key>
    <array>
      <string>open</string>
      <string>/Applications/Borg Wrapper.app</string>
    </array>

    <key>RunAtLoad</key>
    <false/>

    <key>StartCalendarInterval</key>
    <dict>
      <key>Minute</key>
      <integer>0</integer>
    </dict>
  </dict>
</plist>
EOF
launchctl load ~/Library/LaunchAgents/local.borg-wrapper.plist
```

👍

---

## Usage guide

### Backup

```console
$ borg-backup.sh
Creating archive at "borg@185.112.147.115:backup::sunknudsen-macbook-pro-{now:%F-%H%M%S}"
A /Users/sunknudsen/Library/Keychains/4FD89B1C-70AF-58EC-8026-35E97A08F9FE/keychain-2.db-wal
Remote: Storage quota: 314.36 kB out of 10.00 GB used.
Remote: Storage quota: 318.04 kB out of 10.00 GB used.
------------------------------------------------------------------------------
Archive name: sunknudsen-macbook-pro-2020-12-02-081439
Archive fingerprint: 781c5ca9dac166264250bdbe2c87aa1f9fb5f817cafd66d1e720dfdaa443f625
Time (start): Wed, 2020-12-02 08:14:41
Time (end):   Wed, 2020-12-02 08:14:42
Duration: 0.29 seconds
Number of files: 28
Utilization of max. archive size: 0%
------------------------------------------------------------------------------
                       Original size      Compressed size    Deduplicated size
This archive:                6.81 MB            312.77 kB              3.54 kB
All archives:               13.62 MB            625.53 kB            316.18 kB

                       Unique chunks         Total chunks
Chunk index:                      29                   56
------------------------------------------------------------------------------
Done
```

Done

👍

### List

```console
$ borg-list.sh
sunknudsen-macbook-pro-2020-12-02-081338 Wed, 2020-12-02 08:13:41 [c01b3400ec076adb993a2c268cd48810da9acc122614cdc4c87e00075464c1ee]
sunknudsen-macbook-pro-2020-12-02-081439 Wed, 2020-12-02 08:14:41 [781c5ca9dac166264250bdbe2c87aa1f9fb5f817cafd66d1e720dfdaa443f625]
Done
```

Done

👍

### Check

```console
$ borg-check.sh
Done
```

Done

👍

### Restore

```console
$ borg-restore.sh
mount_osxfuse: the file system is not available (1)
umount: /var/folders/dl/mbmsd2m51nb8dvhmtz114j8w0000gn/T/borg: not currently mounted
```

> Heads-up: given “FUSE for macOS” is a third-party extension, macOS prevents using the extension without explicit user consent (granted by clicking “Allow” in “System Preferences” / “Privacy & Security”).

![Allow extension 1](./allow-extension-1.png?shadow=1&width=420)

![Allow extension 2](./allow-extension-2.png?shadow=1&width=668)

```console
$ borg-restore.sh
Restore data and press enter
Done
```

Done

👍

### Prune

```console
$ borg-prune.sh
Enter passphrase for key '/Users/sunknudsen/.ssh/borg':
Keeping archive: sunknudsen-macbook-pro-2020-12-02-081439 Wed, 2020-12-02 08:14:41 [781c5ca9dac166264250bdbe2c87aa1f9fb5f817cafd66d1e720dfdaa443f625]
Pruning archive: sunknudsen-macbook-pro-2020-12-02-081338 Wed, 2020-12-02 08:13:41 [c01b3400ec076adb993a2c268cd48810da9acc122614cdc4c87e00075464c1ee] (1/1)
------------------------------------------------------------------------------
                       Original size      Compressed size    Deduplicated size
Deleted data:               -6.81 MB           -312.76 kB             -3.52 kB
All archives:                6.81 MB            312.77 kB            312.65 kB

                       Unique chunks         Total chunks
Chunk index:                      27                   28
------------------------------------------------------------------------------
Done
```

Done

👍
