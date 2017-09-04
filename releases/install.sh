#!/usr/bin/env bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
APP_NAME="com.lguerrin.browsergopass"

OS=`uname -s`
NC='\033[0m'

function printGreen {
    echo -e "\033[32m$1$NC"
}

function printLightGreen {
    echo -e "\033[92m$1$NC"
}

function printRed {
    echo -e "\033[31m$1$NC"
}

function printYellow {
    echo -e "\033[33m$1$NC"
}

function succesfulInstall {
    printLightGreen "\t\u2713 install OK"
}

function addApp {
    printGreen "\tAdd app..."
}


function detectApp {
    echo "Checking $1..."
    INSTALLED=0
    case ${OS} in
        Linux)

            hash $1 > /dev/null 2>&1
            ;;
        Darwin)
            osascript -e "id of application \"$1\""  > /dev/null 2>&1
            ;;
        *)
            printRed "\u2718Cannot detect app on $OS"
            exit 1
        ;;
    esac

    INSTALLED=$?

    if [ $INSTALLED -eq 0 ]; then
        printYellow "\tInstalled"
    else
        printYellow "\t\u2718 Not found"
    fi
}

case ${OS} in
    Linux)
        TARGET_DIR_CHROME="$HOME/.config/google-chrome/NativeMessagingHosts"
        CHROME_APP="google-chrome"
        TARGET_DIR_FIREFOX="$HOME/.mozilla/native-messaging-hosts/"
        FIREFOX_APP="firefox"
        TARGET_DIR_CHROMIUM="$HOME/.config/chromium/NativeMessagingHosts"
        CHROMIUM_APP="chromium-browser"

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
        printRed "Cannot install on $OS"
        exit 1
    ;;
esac

# Escape host file
ESCAPED_HOST_FILE=${HOST_FILE////\\/}


detectApp "$FIREFOX_APP"
if [ $INSTALLED -eq 0 ]; then
    if [ ! -d "$TARGET_DIR_FIREFOX" ]; then
        printYellow "\tCreates native app folder"
        mkdir -p "$TARGET_DIR_FIREFOX"
    fi

    addApp
    cp "host-firefox.json" "$TARGET_DIR_FIREFOX/$APP_NAME.json"
    sed -i -e "s/%%replace%%/$ESCAPED_HOST_FILE/" "$TARGET_DIR_FIREFOX/$APP_NAME.json"
    succesfulInstall
fi
detectApp "$CHROME_APP"
if [ $INSTALLED -eq 0 ]; then
     if [ ! -d "$TARGET_DIR_CHROME" ]; then
         echo "Creates native app folder"
         mkdir -p "$TARGET_DIR_CHROME"
     fi

     addApp
     cp "host-chrome.json" "$TARGET_DIR_CHROME/$APP_NAME.json"
     sed -i -e "s/%%replace%%/$ESCAPED_HOST_FILE/" "$TARGET_DIR_CHROME/$APP_NAME.json"
     succesfulInstall
fi


if [ -n "$CHROMIUM_APP" ]; then
    detectApp "$CHROMIUM_APP"
    if [ $INSTALLED -eq 0 ]; then
        if [ -d "$TARGET_DIR_CHROMIUM" ]; then
            addApp
            cp "host-chrome.json" "$TARGET_DIR_CHROMIUM/$APP_NAME.json"
            sed -i -e "s/%%replace%%/$ESCAPED_HOST_FILE/" "$TARGET_DIR_CHROMIUM/$APP_NAME.json"
            succesfulInstall
        fi
    fi
fi


echo -e "\n\e[1;42mNow, you can add plugin to browsers.$NC"