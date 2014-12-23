#!/bin/bash
squish --minify-level=full --uglify-level=full
luac -o /tmp/luac.out out.lua
~/lua/bin2c/bin2c /tmp/luac.out > /tmp/code.c
gcc -o test -llua ~/lua/bin2c/main.c
rm -rf out.lua
