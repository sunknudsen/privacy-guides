<!--
Title: How to disable IPv6 on iOS (cellular-only) and macOS and why it’s a big deal for privacy
Description: Learn how to disable IPv6 on iOS (cellular-only) and macOS and why it’s a big deal for privacy.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Publication date: 2020-07-18T10:28:23.605Z
-->

# How to disable IPv6 on iOS (cellular-only) and macOS and why it’s a big deal for privacy

[![How to disable IPv6 on iOS (cellular only) and macOS and why it’s a big deal for privacy - YouTube](how-to-disable-ipv6-on-ios-cellular-only-and-macos-and-why-it-s-a-big-deal-for-privacy.png)](https://www.youtube.com/watch?v=Nzx9T7GtmT4 "How to disable IPv6 on iOS (cellular only) and macOS and why it’s a big deal for privacy - YouTube")

> Heads up: unfortunately this guide will not work on carriers or ISPs that have migrated their networks to IPv6-only.

## iOS guide

**Step 1 (macOS): download and open [Apple Configurator 2](https://support.apple.com/apple-configurator)**

**Step 2 (macOS): create new profile using <kbd>cmd + n</kbd>**

**Step 3 (macOS): configure "General" settings**

![apple-configurator-general](./apple-configurator-general.png?shadow=1)

**Step 4 (iOS): find your APN settings**

Open "Settings", then "Cellular", then "Cellular Data Network".

![ios-cellular-data-network](./ios-cellular-data-network.png?shadow=1&width=240)

**Step 5 (macOS): configure "Cellular" settings**

![apple-configurator-cellular](./apple-configurator-cellular.png?shadow=1)

**Step 6 (macOS): save provisioning profile**

**Step 7 (macOS): connect iPhone to Mac**

**Step 8 (macOS): double-click on iPhone**

![apple-configurator-iphone](./apple-configurator-iphone.png?shadow=1)

**Step 9 (macOS): click on "Profile" tab, then "Add Profiles...", select saved provisioning profile and click "Add"**

![apple-configurator-add-profile](./apple-configurator-add-profile.png?shadow=1)

**Step 10 (iOS): review profile**

Open "Settings", then "Profile Downloaded" and tap "Install"

![ios-install-profile](./ios-install-profile.png?shadow=1&width=240)

## macOS guide

**Step 1: list network interfaces**

```shell
networksetup -listallnetworkservices
```

**Step 2: disable IPv6**

```shell
networksetup -setv6off "Wi-Fi"
networksetup -setv6off "Thunderbolt Ethernet"
```

---

## Want things back the way they were before following this guide? No problem!

**Step 1 (iOS): remove provisioning profile from iPhone**

Open "Settings", then "General", then "Profile", tap on your provisioning profile and tap "Remove Profile".

![ios-remove-profile](./ios-remove-profile.png?shadow=1&width=240)

**Step 2 (macOS): set network interfaces to automatic**

```shell
networksetup -setv6automatic "Wi-Fi"
networksetup -setv6automatic "Thunderbolt Ethernet"
```
