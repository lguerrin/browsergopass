#!/usr/bin/env bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
APP_NAME="com.lguerrin.browsergopass"

OS=`uname -s`
case ${OS} in
    Linux)
        TARGET_DIR_CHROME="$HOME/.config/google-chrome/NativeMessagingHosts"
        TARGET_DIR_FIREFOX="$HOME/.mozilla/native-messaging-hosts/"
        HOST_FILE="$DIR/browsergopass"

        if [ -z `hash firefox` ]; then
            echo "Detecting Firefox"
            if [ ! -d "$TARGET_DIR_FIREFOX" ]; then
                "Creates native app folder"
                mkdir -p "$TARGET_DIR_FIREFOX"
            fi
        fi

        if [ -z `hash google-chrome` ]; then
             echo "Detecting Chrome"
             if [ ! -d "$TARGET_DIR_CHROME" ]; then
                 echo "Creates native app folder"
                 mkdir -p "$TARGET_DIR_CHROME"
             fi
        fi

        ;;
    Darwin)
        TARGET_DIR_CHROME="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
        TARGET_DIR_FIREFOX="$HOME/Library/Application Support/Mozilla/NativeMessagingHosts"
        HOST_FILE="$DIR/browsergopass-wrapper"
        ;;
    *)
        echo "Cannot install on $OS"
        exit 1
    ;;
esac

# Escape host file
ESCAPED_HOST_FILE=${HOST_FILE////\\/}

if [ -d "$TARGET_DIR_CHROME" ]; then
    echo "Installing app for  chrome"
    cp "host-chrome.json" "$TARGET_DIR_CHROME/$APP_NAME.json"
    sed -i -e "s/%%replace%%/$ESCAPED_HOST_FILE/" "$TARGET_DIR_CHROME/$APP_NAME.json"
fi

if [ -d "$TARGET_DIR_FIREFOX" ]; then
    echo "Installing app for firefox"
    cp "host-firefox.json" "$TARGET_DIR_FIREFOX/$APP_NAME.json"
    sed -i -e "s/%%replace%%/$ESCAPED_HOST_FILE/" "$TARGET_DIR_FIREFOX/$APP_NAME.json"
fi

echo "Now, you can add plugins to browsers."