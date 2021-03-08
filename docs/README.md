<!--
Title: Privacy guides docs
Description: Learn how to contribute, get help, peer review and sign the reference material.
Author: Sun Knudsen <https://github.com/sunknudsen>
Publication date: 1970-01-01T00:00:00.000Z
Listed: false
-->

# Privacy guides docs

## How to contribute

First, thanks for contributing. 🙌

**Like the project?** Please star [repo](https://github.com/sunknudsen/privacy-guides).

**Have a recommendation or found a bug?** Please submit [issue](https://github.com/sunknudsen/privacy-guides/issues).

**Found a security vulnerability?** Please report vulnerability using the PGP public key and email found on [sunknudsen.com](https://sunknudsen.com/).

**Fellow privacy and security researcher?** Please [peer review and sign guides](#how-to-peer-review-and-sign-guide).

**Wish to donate?** Please visit [sunknudsen.com/donate](https://sunknudsen.com/donate).

## How to get help

We have you back, you are not alone!

Please use comments on [YouTube](https://www.youtube.com/sunknudsen) or [PeerTube](https://peertube.sunknudsen.com/video-channels/sunknudsen_channel/videos) when possible as others may be able to help (two brains are better than one).

## How to peer review and sign guide

> Heads-up: in order to establish a web of trust, peer reviewers are expected to have public track records.

### Step 1: clone [repo](https://github.com/sunknudsen/privacy-guides)

### Step 2: checkout [draft](https://github.com/sunknudsen/privacy-guides/tree/draft)

### Step 3: review guide and submit recommendations using [issues](https://github.com/sunknudsen/privacy-guides/issues)

Once consensus has been reached (issues are closed) and updated guide has been published to [draft.sunknudsen.com](https://draft.sunknudsen.com/), time for [step 4](#step-4-append-yourself-to-reviewers-comma-separated).

### Step 4: append yourself to `Reviewers` (comma-separated)

Example:

```markdown
<!--
Title: How to append yourself to reviewers
Description: Learn how to append yourself to reviewers.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers: Alice <https://github.com/alice>, Bob <https://github.com/bob>
Publication date: 2021-01-24T13:11:17.464Z
Listed: true
-->
```

### Step 5: submit [signed](#how-to-sign-pull-requests) pull request

👍

## How to sign pull requests

### Step 1: add PGP public key to GitHub account

Go to https://github.com/settings/keys, click “New GPG key”, paste your PGP public key and click “Add GPG key”.

### Step 2: enable Git [signing](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)

Replace `0x1FA767862BBD1305` with your PGP public signing subkey ID.

```shell
git config --global commit.gpgsign true
git config --global gpg.program $(which gpg)
git config --global user.signingkey 0x1FA767862BBD1305
```

### Step 3: submit pull request

👍
