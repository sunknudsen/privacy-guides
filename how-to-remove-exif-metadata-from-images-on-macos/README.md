<!--
Title: How to remove EXIF metadata from images on macOS
Description: Learn how to remove EXIF metadata from images on macOS.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2020-06-25T00:00:00.000Z
Listed: true
-->

# How to remove EXIF metadata from images on macOS

[![How to remove EXIF metadata from images on macOS - YouTube](how-to-remove-exif-metadata-from-images-on-macos.png)](https://www.youtube.com/watch?v=mVMGiMFGgsU "How to remove EXIF metadata from images on macOS - YouTube")

## Installation guide

### Step 1: install [Homebrew](https://brew.sh/)

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

### Step 2: disable analytics

```shell
brew analytics off
```

### Step 3: install [ExifTool](https://exiftool.org/)

```shell
brew install exiftool
```

👍

---

## Usage guide

### View EXIF metadata

```shell
exiftool -n /path/to/image.jpg
```

### Remove EXIF metadata

```shell
exiftool -all= /path/to/image.jpg
```
