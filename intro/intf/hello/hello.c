#include "lua.h"
#include "lauxlib.h"

int main(int argc, char **argv)
{
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    luaL_dostring(L, "print('hello, '.._VERSION)");
    return 0;
}

/* 
sudo apt-get install liblua5.1-0-dev
gcc -I/usr/include/lua5.1 -o hello hello.c -llua5.1 -lm
*/

