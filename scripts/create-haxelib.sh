#!/bin/bash

cd "$(dirname "$0")/../project";

if ! haxe build.hxml;
then
    exit 1;
fi

cd ../;
rm -f ../hxtf.zip;

zip -r ../hxtf.zip \
    src            \
    CHANGELOG.md   \
    LICENSE.md     \
    README.md      \
    haxelib.json   \
    run.n;

rm ../run.n
