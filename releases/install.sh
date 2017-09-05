#!/usr/bin/env bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
APP_NAME="com.lguerrin.browsergopass"

OS=`uname -s`

function detectApp {
    INSTALLED=0
    case ${OS} in
        Linux)
            if [ -z `hash $1` ]; then
                INSTALLED=0
            else
                INSTALLED=1
            fi
            ;;
        Darwin)
            osascript -e "id of application \"$1\""  > /dev/null
            INSTALLED=$?
            ;;
        *)
            echo "Cannot detect app on $OS"
            exit 1
        ;;
    esac
}

case ${OS} in
    Linux)
        TARGET_DIR_CHROME="$HOME/.config/google-chrome/NativeMessagingHosts"
        CHROME_APP="google-chrome"
        TARGET_DIR_FIREFOX="$HOME/.mozilla/native-messaging-hosts/"
        FIREFOX_APP="firefox"
        HOST_FILE="$DIR/browsergopass"
        ;;
    Darwin)
        TARGET_DIR_CHROME="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
        CHROME_APP="Google Chrome"
        TARGET_DIR_FIREFOX="$HOME/Library/Application Support/Mozilla/NativeMessagingHosts"
        FIREFOX_APP="Firefox"
        HOST_FILE="$DIR/browsergopass-wrapper"
        ;;
    *)
        echo "Cannot install on $OS"
        exit 1
    ;;
esac

# Escape host file
ESCAPED_HOST_FILE=${HOST_FILE////\\/}


detectApp "$FIREFOX_APP"
if [ $INSTALLED -eq 0 ]; then
    echo "Detecting Firefox"
    if [ ! -d "$TARGET_DIR_FIREFOX" ]; then
        "Creates native app folder"
        mkdir -p "$TARGET_DIR_FIREFOX"
    fi

    echo "Installing app for firefox"
    cp "host-firefox.json" "$TARGET_DIR_FIREFOX/$APP_NAME.json"
    sed -i -e "s/%%replace%%/$ESCAPED_HOST_FILE/" "$TARGET_DIR_FIREFOX/$APP_NAME.json"
fi
detectApp "$CHROME_APP"
if [ $INSTALLED -eq 0 ]; then
     echo "Detecting Chrome"
     if [ ! -d "$TARGET_DIR_CHROME" ]; then
         echo "Creates native app folder"
         mkdir -p "$TARGET_DIR_CHROME"
     fi

     echo "Installing app for chrome"
    cp "host-chrome.json" "$TARGET_DIR_CHROME/$APP_NAME.json"
    sed -i -e "s/%%replace%%/$ESCAPED_HOST_FILE/" "$TARGET_DIR_CHROME/$APP_NAME.json"
fi


echo "Now, you can add plugins to browsers."