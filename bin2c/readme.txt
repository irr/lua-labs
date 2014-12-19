http://lua-users.org/wiki/BinToCee
http://matthewwild.co.uk/projects/squish/home

:.bashrc

function l2c {
    luac -o /tmp/luac.out $1
    ~/lua/bin2c/bin2c /tmp/luac.out > /tmp/code.c
    gcc -o $2 -llua ~/lua/bin2c/main.c
    echo "$2 OK."
}
