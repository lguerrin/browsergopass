#!/usr/bin/env bash


DIR="$( cd "$( dirname "$0" )" && pwd )"
APP_NAME="com.lguerrin.browsergopass"
TARGET_DIR_CHROME="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
TARGET_DIR_FIREFOX="$HOME/Library/Application Support/Mozilla/NativeMessagingHosts"
HOST_FILE="$DIR/browsergopass-wrapper"
# Escape host file
ESCAPED_HOST_FILE=${HOST_FILE////\\/}

if [ -d "$TARGET_DIR_CHROME" ]; then
    echo "Installing chrome"
    cp "build/chrome/host.json" "$TARGET_DIR_CHROME/$APP_NAME.json"
    sed -i -e "s/%%replace%%/$ESCAPED_HOST_FILE/" "$TARGET_DIR_CHROME/$APP_NAME.json"
fi

if [ -d "$TARGET_DIR_FIREFOX" ]; then
    echo "Installing firefox"
    cp "build/firefox/host.json" "$TARGET_DIR_FIREFOX/$APP_NAME.json"
    sed -i -e "s/%%replace%%/$ESCAPED_HOST_FILE/" "$TARGET_DIR_FIREFOX/$APP_NAME.json"
fi

#mkdir -p "$TARGET_DIR"/../policies/managed/
#cp "$DIR/chrome-policy.json" "$TARGET_DIR"/../policies/managed/"$APP_NAME.json"
