#!/bin/bash

cd "$(dirname "$0")"
cd ..;

zip -r ../hxtf.zip \
    src \
    CHANGELOG.md \
    CONTRIBUTING.md \
    haxelib.json \
    LICENSE.md \
    README.md \
    run.n;
