#include <lua.h>                               
#include <lualib.h>                            
#include <lauxlib.h>                           

static int isquare(lua_State *L){               /* Internal name of func */
    float rtrn = lua_tonumber(L, -1);           /* Get the single number arg */
    printf("Top of square(), nbr=%f\n",rtrn);
    lua_pushnumber(L,rtrn*rtrn);                /* Push the return */
    return 1;                                   /* One return value */
}

/* Register this file's functions with the
 * luaopen_libraryname() function, where libraryname
 * is the name of the compiled .so output. In other words
 * it's the filename (but not extension) after the -o
 * in the cc command.
 *
 * So for instance, if your cc command has -o power.so then
 * this function would be called luaopen_power().
 *
 * This function should contain lua_register() commands for
 * each function you want available from Lua.
 *
*/

int luaopen_test(lua_State *L){
    lua_register(
            L,               /* Lua state variable */
            "square",        /* func name as known in Lua */
            isquare          /* func name in this file */
            );  
    return 0;
}