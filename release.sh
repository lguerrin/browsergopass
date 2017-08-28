#!/usr/bin/env bash

set -e
DIR="$( cd "$( dirname "$0" )" && pwd )"
BROWSERS="firefox chrome"
PLATFORMS="linux darwin"
ARCH="amd64"
OS=`uname -s`

RELEASE_PATH="$DIR/releases/browsergopass"



cd build
for BROWSER in $BROWSERS; do
    cp $DIR/src/$BROWSER/host.json $DIR/releases/host-$BROWSER.json

    cd $BROWSER
    case ${BROWSER} in
        chrome)
            EXT="crx"
            zip ../browsergopass.$EXT *
            ;;
        firefox)
            EXT="xpi"
            ;;
        *)
            echo "Cannot handle browser $BROWSER"
            exit 1
        ;;
    esac
   cd ..
done

cd ..

mv build/browsergopass* releases/

if [ ! -f "releases/browsergopass.crx" ]; then
    echo "Missing chrome extension..."
    exit 1
fi

if [ ! -f "releases/browsergopass.xpi" ]; then
    echo "Missing firefox extension..."
    exit 1
fi

for PLATFORM in $PLATFORMS; do
    if [ ! -d "$RELEASE_PATH" ]; then
        mkdir $RELEASE_PATH
    fi


    GOOS=$PLATFORM GOARCH=$ARCH go build  -o releases/browsergopass/browsergopass


    cd releases
    cp ../browsergopass-wrapper browsergopass.crx browsergopass.xpi install.sh host*.json  browsergopass/
    tar -zcvf browsergopass-$PLATFORM-$ARCH.tar.gz browsergopass
    cd ../
    rm -rf $RELEASE_PATH
done
