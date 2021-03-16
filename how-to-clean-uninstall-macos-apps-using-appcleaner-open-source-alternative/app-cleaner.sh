#! /bin/bash

if [ -z "$1" ]; then
  printf "%s\n" "Usage: app-cleaner.sh /path/to/app.app"
  exit 1
fi

IFS=$'\n'

red=$(tput setaf 1)
normal=$(tput sgr0)

if [ ! -e "$1/Contents/Info.plist" ]; then
  printf "%s\n" "Cannot find app plist"
  exit 1
fi

bundle_identifier=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$1/Contents/Info.plist" 2> /dev/null)

if [ "$bundle_identifier" = "" ]; then
  printf "%s\n" "Cannot find app bundle identifier"
  exit 1
fi

printf "%s\n" "Checking for running processes…"
sleep 1

app_name=$(basename $1 .app)

processes=($(pgrep -afil "$app_name" | grep -v "app-cleaner.sh"))

if [ ${#processes[@]} -gt 0 ]; then
  printf "%s\n" "${processes[@]}"
  printf "$red%s$normal" "Kill running processes (y or n)? "
  read -r answer
  if [ "$answer" = "y" ]; then
    printf "%s\n" "Killing running processes…"
    sleep 1
    for process in "${processes[@]}"; do
      echo $process | awk '{print $1}' | xargs sudo kill 2>&1 | grep -v "No such process"
    done
  fi
fi

home_dir=~

paths=()

paths+=($(find /private/var/db/receipts -iname "*$app_name*.bom" -maxdepth 1 -prune 2>&1 | grep -v "Permission denied"))
paths+=($(find /private/var/db/receipts -iname "*$bundle_identifier*.bom" -maxdepth 1 -prune 2>&1 | grep -v "Permission denied"))

if [ ${#paths[@]} -gt 0 ]; then
  printf "%s\n" "Saving bill of material logs to desktop…"
  sleep 1
  for path in "${paths[@]}"; do
    mkdir -p "$home_dir/Desktop/$app_name"
    lsbom -f -l -s -p f $path > "$home_dir/Desktop/$app_name/$(basename $path).log"
  done
fi

printf "%s\n" "Finding app data…"
sleep 1

locations=(
  "$home_dir/Library"
  "$home_dir/Library/Application Scripts"
  "$home_dir/Library/Application Support"
  "$home_dir/Library/Application Support/CrashReporter"
  "$home_dir/Library/Containers"
  "$home_dir/Library/Caches"
  "$home_dir/Library/HTTPStorages"
  "$home_dir/Library/Group Containers"
  "$home_dir/Library/Internet Plug-Ins"
  "$home_dir/Library/LaunchAgents"
  "$home_dir/Library/Logs"
  "$home_dir/Library/Preferences"
  "$home_dir/Library/Preferences/ByHost"
  "$home_dir/Library/Saved Application State"
  "$home_dir/Library/WebKit"
  "/Library"
  "/Library/Application Support"
  "/Library/Application Support/CrashReporter"
  "/Library/Caches"
  "/Library/Extensions"
  "/Library/Internet Plug-Ins"
  "/Library/LaunchAgents"
  "/Library/LaunchDaemons"
  "/Library/Logs"
  "/Library/Preferences"
  "/Library/PrivilegedHelperTools"
  "/private/var/db/receipts"
  "/usr/local/bin"
  "/usr/local/etc"
  "/usr/local/opt"
  "/usr/local/sbin"
  "/usr/local/share"
  "/usr/local/var"
  $(getconf DARWIN_USER_CACHE_DIR | sed "s/\/$//")
  $(getconf DARWIN_USER_TEMP_DIR | sed "s/\/$//")
)

paths=($1)

for location in "${locations[@]}"; do
  paths+=($(find "$location" -iname "*$app_name*" -maxdepth 1 -prune 2>&1 | grep -v "No such file or directory" | grep -v "Operation not permitted" | grep -v "Permission denied"))
done

for location in "${locations[@]}"; do
  paths+=($(find "$location" -iname "*$bundle_identifier*" -maxdepth 1 -prune 2>&1 | grep -v "No such file or directory" | grep -v "Operation not permitted" | grep -v "Permission denied"))
done

paths=($(printf "%s\n" "${paths[@]}" | sort -u));

printf "%s\n" "${paths[@]}"

printf "$red%s$normal" "Move app data to trash (y or n)? "
read -r answer
if [ "$answer" = "y" ]; then
  printf "%s\n" "Moving app data to trash…"
  sleep 1
  posixFiles=$(printf ", POSIX file \"%s\"" "${paths[@]}" | awk '{print substr($0,3)}')
  osascript -e "tell application \"Finder\" to delete { $posixFiles }" > /dev/null
  printf "%s\n" "Done"
fi
