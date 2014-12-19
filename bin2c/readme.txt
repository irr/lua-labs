http://lua-users.org/wiki/BinToCee
http://matthewwild.co.uk/projects/squish/home

luac ~/lua/utils/srt.lua
bin2c luac.out > code.c
gcc -o test -llua main.c

