#!/bin/bash

cd "$(dirname "$0")"
cd ..;

zip -r ../hxtf.zip \
    src \
    CHANGELOG.md \
    LICENSE.md \
    README.md \
    haxelib.json \
    run.n;
