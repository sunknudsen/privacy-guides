<!--
Title: How to disable CUPS printer job history on macOS
Description: Learn how to disable CUPS printer job history on macOS.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>, Carl P. Corliss <https://github.com/rabbitt>
Reviewers:
Publication date: 2022-10-29T13:05:18.112Z
Listed: true
-->

# How to disable CUPS printer job history on macOS

[![macOS stores a copy of everything one prints forever](macos-stores-a-copy-of-everything-one-prints-forever.jpeg)](https://www.youtube.com/watch?v=eAgfeVNKdoo "macOS stores a copy of everything one prints forever")

## Requirements

- Computer running macOS Monterey or Ventura

## Setup guide

### Step 1: clear job history

> Heads-up: purges `/var/spool/cups`.

```shell
$ cancel -a -x
```

### Step 2: create `/usr/local/sbin` directory

```shell
sudo mkdir -p /usr/local/sbin
sudo chown ${USER}:admin /usr/local/sbin
```

### Step 3: create `cups.sh` script (see CUPS [docs](https://www.cups.org/doc/man-cupsd.conf.html))

```shell
cat << "EOF" > /usr/local/sbin/cups.sh
#! /bin/sh

set -e

if cupsctl | grep --quiet PreserveJobHistory=no; then
  exit 0
fi

cupsctl MaxJobTime=5m PreserveJobFiles=no PreserveJobHistory=no
EOF
```

### Step 4: make `cups.sh` executable

```shell
chmod +x /usr/local/sbin/cups.sh
```

### Step 5: create `local.cups.plist` launch daemon

> Heads-up: used to make sure user-defined config persists macOS updates.

```shell
cat << "EOF" | sudo tee /Library/LaunchDaemons/local.cups.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>local.cups</string>

    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/sbin/cups.sh</string>
    </array>

    <key>RunAtLoad</key>
    <true/>
  </dict>
</plist>
EOF
```

### Step 6: reboot

👍

---

## Want things back the way they were before following this guide? No problem!

### Step 1: delete `cups.sh` script

```shell
sudo rm /usr/local/sbin/cups.sh
```

### Step 2: delete `local.cups.plist` launch daemon

```shell
sudo rm /Library/LaunchDaemons/local.cups.plist
```

### Step 3: revert user-defined config to CUPS defaults

```shell
cupsctl MaxJobTime= PreserveJobFiles= PreserveJobHistory=
```

### Step 4: reboot

👍
