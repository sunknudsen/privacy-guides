<!--
Title: How to spoof (anonymize) your MAC address and hostname automatically at boot on macOS
Description: Learn how to spoof (anonymize) your MAC address and hostname automatically at boot on macOS.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Publication date: 2020-05-19T00:00:00.000Z
-->

# How to spoof (anonymize) your MAC address and hostname automatically at boot on macOS

[![How to spoof (anonymize) your MAC address and hostname automatically at boot on macOS - YouTube](how-to-spoof-anonymize-your-mac-address-and-hostname-automatically-at-boot-on-macos.png)](https://www.youtube.com/watch?v=ASXANpr_zX8 "How to spoof (anonymize) your MAC address and hostname automatically at boot on macOS - YouTube")

> Heads up: unfortunately this guide does not work on Macs equipped with the new T2 chip running macOS Mojave. If that’s your case, please consider upgrading to Catalina.

### Step 1: create `/usr/local/sbin` folder

```shell
sudo mkdir /usr/local/sbin
sudo chown $(whoami):admin /usr/local/sbin/
```

### Step 2: create `spoof.sh` script

> When copy/pasting commands that start with `cat << "EOF"`, select all lines (from `cat << "EOF"` to `EOF`) at once as they are part of the same (single) command

```shell
cat << "EOF" > /usr/local/sbin/spoof.sh
#! /bin/sh

set -e

export LC_CTYPE=C

dirname=`dirname "${BASH_SOURCE}"`

# Spoof computer name
model_name=`system_profiler SPHardwareDataType | awk '/Model Name/ {$1=$2=""; print $0}' | sed -e 's/^[ ]*//'`
first_name=`sed "$(jot -r 1 1 2048)q;d" $dirname/first_names.txt | sed -e 's/[^a-zA-Z]//g'`
computer_name=`echo "$first_name’s $model_name"`
host_name=`echo $computer_name | sed -e 's/’//g' | sed -e 's/ /-/g'`
sudo scutil --set ComputerName "$computer_name"
sudo scutil --set LocalHostName "$host_name"
sudo scutil --set HostName "$host_name"
echo "Spoofed hostname to $host_name"

# Spoof MAC address of en0 interface
mac_address_prefix=`sed "$(jot -r 1 1 768)q;d" $dirname/mac_address_prefixes.txt | sed -e 's/[^A-F0-9:]//g'`
mac_address_suffix=`openssl rand -hex 3 | sed 's/\(..\)/\1:/g; s/.$//'`
mac_address=`echo "$mac_address_prefix:$mac_address_suffix" | awk '{print toupper($0)}'`
sudo ifconfig en0 ether "$mac_address"
echo "Spoofed MAC address of en0 interface to $mac_address"
EOF
```

Ok, a lot is happening here. Let’s break it down into reviewable pieces.

```shell
set -e
```

Exit on error

```shell
export LC_CTYPE=C
```

Fix `sed: RE error: illegal byte sequence` error

```shell
dirname=`dirname "${BASH_SOURCE}"`
```

Set variable `dirname` to path of `spoof.sh`

```shell
model_name=`system_profiler SPHardwareDataType | awk '/Model Name/ {$1=$2=""; print $0}' | sed -e 's/^[ ]*//'`
```

Set variable `model_name` to the model of your Mac

```shell
first_name=`sed "$(jot -r 1 1 2048)q;d" $dirname/first_names.txt | sed -e 's/[^a-zA-Z]//g'`
```

Set variable `first_name` to random first name found in `first_names.txt`

```shell
computer_name=`echo "$first_name’s $model_name"`
host_name=`echo $computer_name | sed -e 's/’//g' | sed -e 's/ /-/g'`
```

Set variables `computer_name` and `host_name` using values from variables `first_name`, `model_name` and `computer_name`

```shell
sudo scutil --set ComputerName "$computer_name"
sudo scutil --set LocalHostName "$host_name"
sudo scutil --set HostName "$host_name"
echo "Spoofed hostname to $host_name"
```

Set `ComputerName`, `LocalHostName` and `HostName` using `scutil` and echo spoofed computer name

```shell
mac_address_prefix=`sed "$(jot -r 1 1 768)q;d" $dirname/mac_address_prefixes.txt | sed -e 's/[^A-F0-9:]//g'`
```

Set variable `mac_address_prefix` to random Apple MAC address prefix found in `mac_address_prefixes.txt`

```shell
mac_address_suffix=`openssl rand -hex 3 | sed 's/\(..\)/\1:/g; s/.$//'`
```

Set variable `mac_address_suffix` to random value genereated by OpenSSL

```shell
mac_address=`echo "$mac_address_prefix:$mac_address_suffix" | awk '{print toupper($0)}'`
```

Set variable `mac_address` using values from variables `mac_address_prefix` and `mac_address_suffix` and convert to upper case

```shell
sudo ifconfig en0 ether "$mac_address"
echo "Spoofed MAC address of en0 interface to $mac_address"
```

Set spoofed MAC address using `ifconfig` and echo spoofed MAC address

### Step 3: make `spoof.sh` executable

```shell
chmod +x /usr/local/sbin/spoof.sh
```

### Step 4: download [first_names.txt](first_names.txt)

This list includes the top 2048 most popular baby names from the [USA Social Security Administration](https://www.ssa.gov/oact/babynames/limits.html).

```shell
curl -o /usr/local/sbin/first_names.txt https://sunknudsen.com/static/media/privacy-guides/how-to-spoof-anonymize-your-mac-address-and-hostname-automatically-at-boot-on-macos/first_names.txt
```

### Step 5: download [mac_address_prefixes.txt](mac_address_prefixes.txt)

This list includes 768 Apple MAC address prefixes.

```shell
curl -o /usr/local/sbin/mac_address_prefixes.txt https://sunknudsen.com/static/media/privacy-guides/how-to-spoof-anonymize-your-mac-address-and-hostname-automatically-at-boot-on-macos/mac_address_prefixes.txt
```

### Step 6: create `local.spoof.plist` launch daemon

This step is responsible for running `spoof.sh` every time your Mac boots.

```shell
cat << "EOF" | sudo tee /Library/LaunchDaemons/local.spoof.plist > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>spoof.sh</string>

        <key>ProgramArguments</key>
        <array>
            <string>/usr/local/sbin/spoof.sh</string>
        </array>

        <key>RunAtLoad</key>
        <true/>
    </dict>
</plist>
EOF
```

### Step 7: reboot and confirm hostname and MAC address have been spoofed

```shell
# Spoofed hostname
scutil --get HostName

# Spoofed MAC address
ifconfig en0 | grep ether | awk '{print $2}'

# Hardware MAC address
networksetup -listallhardwareports | awk -v RS= '/en0/{print $NF}'
```

"Spoofed hostname" is random and "Spoofed MAC address" doesn’t match "Hardware MAC address"?

👍

---

## Want things back the way they were before following this guide? No problem!

### Step 1: set computer name, local hostname and hostname

Replace `John Doe` with a value to your liking. Don’t forget to replace empty spaces by `-` for `LocalHostName` and `HostName`.

```shell
sudo scutil --set ComputerName "John Doe"
sudo scutil --set LocalHostName "John-Doe"
sudo scutil --set HostName "John-Doe"
```

### Step 2: set MAC address to factory value

Given MAC address spoofing is ephemeral, deleting the `/Library/LaunchDaemons/local.spoof.plist` launch daemon and rebooting will reset your MAC address to its factory value.

```shell
sudo rm /Library/LaunchDaemons/local.spoof.plist
```

### Step 3 (optional): delete script and datasets

```shell
rm /usr/local/sbin/spoof.sh
rm /usr/local/sbin/first_names.txt
rm /usr/local/sbin/mac_address_prefixes.txt
```
