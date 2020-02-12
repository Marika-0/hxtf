#!/bin/bash

cd "$(dirname "$0")";

if ! sh create-haxelib.sh;
then
    exit 1;
fi

haxelib install ../../hxtf.zip;
