http://lua-users.org/wiki/BinToCee

luac ~/lua/utils/srt.lua
bin2c luac.out > code.c
gcc -o test -llua main.c

