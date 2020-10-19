#!/bin/sh
set -e

(cd tndlpt && ./build.sh)
(cd tndvgm && ./build.sh)

DIR=$(mktemp -d)
cp tndlpt/lotech.com "$DIR/"
cp tndlpt/loreset.exe "$DIR/"
cp tndvgm/lotest.exe "$DIR/"
cp tndvgm/lotest.vgz "$DIR/"

rm -f lotech.zip
zip -9j lotech.zip "$DIR"/*

rm -rf "$DIR"
