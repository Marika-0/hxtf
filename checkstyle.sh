#!/usr/bin/env bash

SOURCE_DIRS=(
    src
    framework/src/hxtf
);


for ((i=0; i<${#SOURCE_DIRS[*]}; i++));
do :
    SOURCE_DIRS[$i]="-s ${SOURCE_DIRS[$i]}";
done

printf "\n";
haxelib run checkstyle ${SOURCE_DIRS[*]};
printf "\n";
