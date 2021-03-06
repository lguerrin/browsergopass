#!/usr/bin/env bash


DIR="$( cd "$( dirname "$0" )" && pwd )"

mkdir -p $DIR/build/chrome $DIR/build/firefox
cd src


BROWSERS="chrome firefox"

for BROWSER in $BROWSERS; do
    echo "Build for $BROWSER"
    cp common/*.svg common/*.png common/script.js common/*.html common/*.css $BROWSER/manifest.json $DIR/build/$BROWSER/
done