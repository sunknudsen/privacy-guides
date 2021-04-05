<!--
Title: How to use Time Machine and APFS snapshots on macOS
Description: Learn how to use Time Machine and APFS snapshots on macOS.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2021-04-02T17:40:53.608Z
Listed: true
-->

# How to use Time Machine and APFS snapshots on macOS

## Time Machine setup guide

### Step 1: exclude folders from Time Machine

> Heads-up: excluded folders vary depending on use case.

![Format Time Machine drive](./exclude.png?shadow=1)

### Step 2: format Time Machine disk as “Mac OS Extended (Journaled, Encrypted)” using “Disk Utility”

> WARNING: DATA ON TIME MACHINE DISK WILL BE PERMANENTLY DELETED.

![Format Time Machine drive](./format.png?shadow=1)

### Step 3: enable “Encrypt Backup Disk” and click “Use as Backup Disk”

![Format Time Machine drive](./enable-time-machine.png?shadow=1&width=568)

### Step 4: confirm encryption is enabled and enable “Show Time Machine in menu bar”

![Format Time Machine drive](./confirm-encryption.png?shadow=1)

Encrypted

👍

## Time Machine usage guide

### Create backup

Click “Time Machine” menu bar icon and then “Back Up Now” or run `tmutil startbackup`.

### Delete specific backup

Heads-up: use `tmutil listbackups` to list backups.

```shell
sudo tmutil delete "/Volumes/LaCie/Backups.backupdb/Sun’s MacBook Pro/2021-04-05-082332"
```

## APFS snapshot usage guide

### Create local APFS snapshot

```shell
tmutil localsnapshot
```

### List local APFS snapshots

```shell
tmutil listlocalsnapshots /
```

### Mount local read-only APFS snapshot

Heads-up: use `umount /tmp/snapshot` to unmount snapshot.

Replace `com.apple.TimeMachine.2021-04-05-082935.local` with snapshot from [List local APFS snapshots](#list-local-apfs-snapshots).

```shell
mkdir -p /tmp/snapshot
mount_apfs -s com.apple.TimeMachine.2021-04-05-082935.local / /tmp/snapshot
open /tmp/snapshot
```

### Restore local APFS snapshot

Restart computer and press `cmd+r` to boot to recovery mode.

Select “Restore From Time Machine Backup”, then “Macintosh HD”, choose local snapshot, click “Continue” and “Continue” again to confirm.

### Delete specific local APFS snapshot

> Heads-up: use `tmutil listlocalsnapshotdates` to list local snapshot dates.

```
tmutil deletelocalsnapshots 2021-04-05-082935
```

### Delete all local APFS snapshot

```
tmutil deletelocalsnapshots /
```
