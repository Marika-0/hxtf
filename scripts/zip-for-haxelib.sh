#!/bin/bash

cd "$(dirname "$0")"
cd ..;

rm -f ../hxtf.zip;

zip -r ../hxtf.zip \
    src \
    CHANGELOG.md \
    LICENSE.md \
    README.md \
    haxelib.json \
    run.n;
