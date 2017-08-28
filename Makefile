build: build-go build-browserify build-ext

build-go:
	go build

build-browserify:
	browserify src/common/script.browserify.js -o src/common/script.js

build-ext:
	./build-ext.sh

install:
	./install.sh
