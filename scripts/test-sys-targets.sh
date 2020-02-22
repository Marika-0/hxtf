#!/bin/bash

cd "$(dirname "$0")";
reset;

if ! sh quick-install-haxelib.sh;
then
    exit 1;
fi

cd ../test;

printf "\n" | haxelib run hxtf -r;

haxelib run hxtf \
    cpp          \
    defines1     \
    defines2     \
    defines3     \
    hl           \
    java         \
    lua          \
    neko         \
    php          \
    python;
