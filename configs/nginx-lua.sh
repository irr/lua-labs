#!/bin/bash

# sudo apt-get install lua5.1 lua5.1-doc luarocks

# http://wiki.nginx.org/HttpLuaModule#Installation

# ngx_devel_kit: http://github.com/simpl/ngx_devel_kit/tags
# ngx_lua: http://github.com/chaoslawful/lua-nginx-module/tags

export LUA_LIB=/usr/local/lib
export LUA_INC=/usr/local/include 

./configure --with-http_ssl_module \
            --prefix=/data/Lua/nginx \
            --add-module=/data/Lua/ngx_devel_kit \
            --add-module=/data/Lua/lua-nginx-module
            
make -j4
make install
