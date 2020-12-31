<!--
Title: How to reset app privacy permissions on macOS
Description: Learn how to reset app privacy permissions on macOS.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2020-12-31T14:52:42.907Z
Listed: true
-->

# How to reset app privacy permissions on macOS

## Guide

> Heads-up: make sure [System Integrity Protection](https://support.apple.com/en-us/HT204899) (SPI) is enabled using `csrutil status`.

> Heads-up: available privacy permissions are `Accessibility`, `AddressBook`, `All`, `AppleEvents`, `Calendar`, `Camera`, `ContactsFull`, `ContactsLimited`, `Facebook`, `FileProviderDomain`, `FileProviderPresence`, `LinkedIn`, `Liverpool`, `Location`, `MediaLibrary`, `Microphone`, `Motion`, `Photos`, `PhotosAdd`, `PostEvent`, `Reminders`, `ScreenCapture`, `ShareKit`, `SinaWeibo`, `Siri`, `SpeechRecognition`, `SystemPolicyAllFiles`, `SystemPolicyDesktopFolder`, `SystemPolicyDeveloperFiles`, `SystemPolicyDocumentsFolder`, `SystemPolicyNetworkVolumes`, `SystemPolicyRemovableVolumes`, `SystemPolicySysAdminFiles`, `SystemPolicyDownloadsFolder`, `TencentWeibo`, `Twitter`, `Ubiquity`, `Willow`.

> Heads-up: “Location Services” is handled differently so `tccutil` has no effect.

### Reset single privacy permission for single app

```console
$ mdls -name kMDItemCFBundleIdentifier -r /Applications/Signal.app
org.whispersystems.signal-desktop

$ tccutil reset Camera org.whispersystems.signal-desktop
Successfully reset Camera approval status for org.whispersystems.signal-desktop
```

### Reset single privacy permission for all apps

```console
$ tccutil reset Camera
Successfully reset Camera
```

### Reset all privacy permissions for all apps

```console
$ tccutil reset All
Successfully reset All
```
