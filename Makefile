build: build-go build-browserify build-ext

build-go:
	go build

build-browserify:
	browserify add-on/common/script.browserify.js -o add-on/common/script.js

build-ext:
	./build-ext.sh

install:
	./install.sh
