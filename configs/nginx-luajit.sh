#!/bin/bash

# sudo apt-get install lua5.1 lua5.1-doc luarocks

# http://wiki.nginx.org/HttpLuaModule#Installation

# ngx_devel_kit: http://github.com/simpl/ngx_devel_kit/tags
# ngx_lua: http://github.com/chaoslawful/lua-nginx-module/tags

export LUAJIT_LIB=/data/Lua/LuaJIT/lib
export LUAJIT_INC=/data/Lua/LuaJIT/include/luajit-2.0

./configure --prefix=/data/Lua/nginx \
            --add-module=/data/Lua/ngx_devel_kit-0.2.17 \
            --add-module=/data/Lua/lua-nginx-module-0.7.13

./configure --with-http_ssl_module \
            --prefix=/data/Lua/nginx 
            
make -j4
make install
