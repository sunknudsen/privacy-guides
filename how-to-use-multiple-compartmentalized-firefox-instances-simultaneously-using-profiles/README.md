<!--
Title: How to use multiple compartmentalized Firefox instances simultaneously using profiles
Description: Learn how to use multiple compartmentalized Firefox instances simultaneously using profiles.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2020-05-13T00:00:00.000Z
Listed: true
-->

# How to use multiple compartmentalized Firefox instances simultaneously using profiles

[![How to use multiple compartmentalized Firefox instances using profiles - YouTube](how-to-use-multiple-compartmentalized-firefox-instances-using-profiles.png)](https://www.youtube.com/watch?v=Upib_vq_EB8 "How to use multiple compartmentalized Firefox instances using profiles - YouTube")

## Guide

### Step 1: create Firefox profile

```shell
/Applications/Firefox.app/Contents/MacOS/firefox-bin -p
```

### Step 2: open “Script Editor” and paste following snippet

> Heads-up: replace `work` with profile name from [step 1](#step-1-create-firefox-profile).

```
do shell script "nohup /Applications/Firefox.app/Contents/MacOS/firefox-bin -p \"work\" --no-remote > /dev/null 2>&1 &"
```

![script-editor-step-1](./script-editor-step-1.png?shadow=1)

### Step 3: export script as application

Click “File”, then “Export…”, set “Export As” filename to “Firefox work” (or any other filename), select “Applications” folder (in “Favorites”), select “Application” file format and click “Save”.

![script-editor-step-2](./script-editor-step-2.png?shadow=1)

### Step 4: configure app as agent app

> Heads-up: replace `Firefox work` with filename from [step 3](#step-3-export-script-as-application).

```shell
defaults write "/Applications/Firefox work.app/Contents/Info.plist" LSUIElement -bool yes
```

### Step 5 (optional): replace default icon with Firefox icon

> Heads-up: replace `Firefox work` with filename from [step 3](#step-3-export-script-as-application).

```shell
cp "/Applications/Firefox.app/Contents/Resources/firefox.icns" "/Applications/Firefox work.app/Contents/Resources/applet.icns"
```

👍
