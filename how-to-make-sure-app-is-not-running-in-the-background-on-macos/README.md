<!--
Title: How to make sure app is not running in the background on macOS
Description: Learn how to how to make sure app is not running in the background on macOS.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2021-01-04T15:53:29.749Z
Listed: true
-->

# How to make sure app is not running in the background on macOS

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command
- When copy/pasting commands that start with `cat << "EOF"`, select all lines at once (from `cat << "EOF"` to `EOF` inclusively) as they are part of the same (single) command

## Setup guide

> Heads-up: following steps illustrate how to make sure “Adobe Creative Suite” is not running in the background, but same logic should apply any app.

### Step 1: find app launch agent and daemon bundle identifier prefix

```console
$ ls -A1 {,~}/Library/LaunchAgents/ /Library/LaunchDaemons
/Library/LaunchAgents/:
at.obdev.LittleSnitchHelper.plist
at.obdev.LittleSnitchUIAgent.plist
com.adobe.ARMDCHelper.cc24aef4a1b90ed56a725c38014c95072f92651fb65e1bf9c8e43c37a23d420d.plist
com.adobe.AdobeCreativeCloud.plist
com.adobe.GC.AGM.plist
com.adobe.GC.Invoker-1.0.plist
com.adobe.ccxprocess.plist

/Library/LaunchDaemons:
at.obdev.littlesnitchd.plist
com.adobe.ARMDC.Communicator.plist
com.adobe.ARMDC.SMJobBlessHelper.plist
com.adobe.acc.installer.v2.plist
com.adobe.agsservice.plist
com.apogee.DuetDetect.plist
com.apple.installer.osmessagetracing.plist
local.pf.plist
local.pmset.plist
local.spoof.plist
org.virtualbox.startup.plist
org.wireshark.ChmodBPF.plist

/Users/sunknudsen/Library/LaunchAgents/:
com.adobe.GC.Invoker-1.0.plist
local.borg-wrapper.plist
org.virtualbox.vboxwebsrv.plist
```

com.adobe

👍

### Step 2: disable app launch agents and daemons

> Heads-up: don’t worry if you see “Could not find specified service” warnings.

```shell
BUNDLE_IDENTIFIER_PREFIX="com.adobe"
launchctl unload -w {,~}/Library/LaunchAgents/$BUNDLE_IDENTIFIER_PREFIX*.plist
sudo launchctl unload -w /Library/LaunchDaemons/$BUNDLE_IDENTIFIER_PREFIX*.plist
```

### Step 3: disable app extensions

Open “System Preferences”, then click “Extensions” and uncheck app extensions (if any).

![core-sync](./core-sync.png?shadow=1)

### Step 4: add `kill-apps` helper to `.zshrc`

> Heads-up: following step assumes macOS is configured to use “Z shell” (running `echo $SHELL` should return `/bin/zsh`).

```shell
cat << "EOF" >> ~/.zshrc

# Kill apps that match string
function kill-apps() {
  if [ -z "$1" ]; then
    printf "%s\n" "Usage: kill-apps string"
    return 1
  fi
  printf "%s\n" "Finding apps that match \"$1\"..."
  pgrep -afil "$1"
  printf "%s" "Kill apps (y or n)? "
  read -r answer
  if [ "$answer" = "y" ]; then
    pgrep -afi "$1" | xargs sudo kill 2>&1 && echo "Done"
  fi
}
EOF
source ~/.zshrc
```

👍

## Usage guide

### Make sure “Adobe Creative Suite” is not running in the background

```console
$ kill-apps adobe
Finding apps that match "adobe"...
46639 /Library/Application Support/Adobe/Adobe Desktop Common/IPCBox/AdobeIPCBroker.app/Contents/MacOS/AdobeIPCBroker -launchedbyvulcan /Applications/Adobe Premiere Pro 2020/Adobe Premiere Pro 2020.app/Contents/MacOS/Adobe Premiere Pro 2020
46645 /Library/Application Support/Adobe/Creative Cloud Libraries/CCLibrary.app/Contents/MacOS/../libs/node /Library/Application Support/Adobe/Creative Cloud Libraries/CCLibrary.app/Contents/MacOS/../js/server.js
46653 /Applications/Utilities/Adobe Creative Cloud Experience/CCXProcess/CCXProcess.app/Contents/MacOS/../libs/Adobe_CCXProcess.node /Applications/Utilities/Adobe Creative Cloud Experience/CCXProcess/CCXProcess.app/Contents/MacOS/../js/main.js
46655 /Applications/Adobe Premiere Pro 2020/Adobe Premiere Pro 2020.app/Contents/MacOS/LogTransport2.app/Contents/MacOS/LogTransport2 86E222CE52861AEA0A490D4D@AdobeID 1 0 NOVALUE NOVALUE
Kill apps (y or n)? y
Password:
Done
```

Done

👍
