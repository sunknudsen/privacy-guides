<!--
Title: How to disable app launch agents, daemons and extensions
Description: Learn how to how to disable app launch agents, daemons and extensions.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2021-01-04T15:53:29.749Z
Listed: true
-->

# How to disable app launch agents, daemons and extensions

## Guide

> Heads-up: following steps are used to “tame” Adobe Creative Suite, but same logic can apply to all apps.

### Step 1: disable launch agents and daemons

> Heads-up: don’t worry if you see “Could not find specified service” warnings.

```shell
launchctl unload -w {,~}/Library/LaunchAgents/com.adobe.*.plist
sudo launchctl unload -w /Library/LaunchDaemons/com.adobe.*.plist
```

### Step 2: disable extensions

Open “System Preferences”, then click “Extensions” and disable “Core Sync / Finder Extensions”.

![core-sync](./core-sync.png?shadow=1)

### Step 3: append kill function to `.zshrc`

> Heads-up: following step assumes macOS is configured to use “Z shell” (running `echo $SHELL` should return `/bin/zsh`).

```shell
cat << "EOF" >> ~/.zshrc

# Kill Adobe
function kill-adobe() {
  pgrep -afi adobe | xargs sudo kill 2>&1
}
EOF
```

👍
