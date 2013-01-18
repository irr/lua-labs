#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int main (int argc, char **argv) {
    
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    if (luaL_loadfile(L, argv[1]) != 0)
        fprintf(stderr, "error: %s\n", lua_tostring(L, -1));
    else if (lua_pcall(L, 0, 0, 0) != 0)
        fprintf(stderr, "error: %s\n", lua_tostring(L, -1));
    else {
        lua_getglobal(L, "result");
        printf("resultado: %f\n\n", lua_tonumber(L, -1));
    }
    
    lua_close(L);
    return 0;
}

