<!--
Title: How to disable CUPS pinter job history on macOS
Description: Learn how to disable CUPS pinter job history on macOS.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2022-10-29T13:05:18.112Z
Listed: true
-->

# How to disable CUPS pinter job history on macOS

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

### Step 3: create `cups.sh` script

```shell
cat << "EOF" > /usr/local/sbin/cups.sh
#! /bin/sh

set -e

if grep -qe '^PreserveJobHistory Off$' /etc/cups/cupsd.conf; then
  exit 0
fi

echo "PreserveJobHistory Off" | sudo tee -a /etc/cups/cupsd.conf

sudo launchctl unload /System/Library/LaunchDaemons/org.cups.cupsd.plist

sudo launchctl load /System/Library/LaunchDaemons/org.cups.cupsd.plist
EOF
```

### Step 4: make `cups.sh` executable

```shell
chmod +x /usr/local/sbin/cups.sh
```

### Step 5: create `local.cups.plist` launch daemon

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
