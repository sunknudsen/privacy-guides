<!--
Title: How to generate bitcoin-dataset
Description: Learn how to generate bitcoin-dataset.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2022-03-01T17:31:42.392Z
Listed: true
-->

# How to generate bitcoin-dataset

## Requirements

- [Hardened Bitcoin node](../..) (with at least 2TB of SSD storage)
- Linux or macOS computer

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command

## Guide

### Step 1: create bitcoin-dataset directory

```console
$ mkdir -p /root/bitcoin-dataset

$ cd /root/bitcoin-dataset
```

### Step 2: create bitcoind and electrs archive

```console
$ tar \
  --create \
  --directory /var/lib/bitcoind \
  --use-compress-program=lz4 \
  --verbose \
  anchors.dat \
  blocks \
  chainstate \
  fee_estimates.dat \
  indexes \
  mempool.dat \
  peers.dat | \
  split \
  --bytes 10G \
  --numeric-suffixes \
  - \
  bitcoind.tar.lz4.part

$ tar \
  --create \
  --directory /var/lib/electrs \
  --use-compress-program=lz4 \
  --verbose \
  . | \
  split \
  --bytes 10G \
  --numeric-suffixes \
  - \
  electrs.tar.lz4.part
```

### Step 3: create bitcoind and electrs archive checksums

```shell
b3sum \
  bitcoind.tar.lz4.part* \
  electrs.tar.lz4.part* \
  > BLAKE3CHECKSUMS
```

### Step 4: sign checksums

```shell
gpg \
  --detach-sig \
  --armor \
  --output \
  BLAKE3CHECKSUMS.asc \
  BLAKE3CHECKSUMS
```

### Step 5: create torrent

```console
$ cd

$ transmission-create \
  --private \
  --tracker https://tracker.sunknudsen.com/announce \
  --outfile bitcoin-dataset.torrent \
  bitcoin-dataset
```

### Step 6: sign torrent

```shell
gpg \
  --detach-sig \
  --armor \
  --output \
  bitcoin-dataset.torrent.asc \
  bitcoin-dataset.torrent
```
