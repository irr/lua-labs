lua-labs
-----------

**lua-labs**  is a set of sample codes whose main purpose is to experiment and test *Lua* and *[OpenResty]/[Apache]*

```shell
yum install readline-devel pcre-devel openssl-devel
tar xfva ngx_openresty-1.2.8.6.tar.gz
cd ngx_openresty-1.2.8.6
./configure --prefix=/opt/openresty --with-luajit --with-http_iconv_module --with-http_stub_status_module
make install
```

```shell
apt-get install libreadline-dev libpcre3-dev libssl-dev
tar xfva ngx_openresty-1.2.8.6.tar.gz
cd ngx_openresty-1.2.8.6
./configure --prefix=/opt/openresty --with-luajit --with-http_iconv_module --with-http_stub_status_module
make -j4 
make install
```

```shell
wget http://luajit.org/download/LuaJIT-2.0.2.tar.gz
tar xfva LuaJIT-2.0.2.tar.gz
cd LuaJIT-2.0.2
make && make install
```

[LuaJIT]
-----------

Before you compile LuaJIT, change LUA_ROOT from /usr/local to /usr in src/luaconf.h
```shell
#define LUA_ROOT    "/usr/"
```
Make sure you load *luarocks* in every script to share libraries with [LuaJIT] and lua interpreter, as following:
```shell
require("luarocks.loader")
```

Dependencies
-----------

```shell
apt-get install libzmq-dev libsqlite3-dev libmysqlclient-dev libpcre3-dev
yum install czmq-devel sqlite-devel mysql-devel pcre-devel
```

Libraries
-----------

* [OpenResty]: A full-fledged web application server by bundling the standard Nginx core, lots of 3rd-party Nginx modules, as well as most of their external dependencies

* [iconv]: Lua binding to the POSIX 'iconv' library
* [lua-cjson]: Lua CJSON provides JSON support for Lua
* [lua-llthreads]: Low-Level threads(pthreads or WIN32 threads) for Lua
* [luaposix]: Lua bindings for POSIX APIs
* [luarocks]: Deployment and management system for Lua modules
* [luasql-mysql]: LuaSQL is a simple interface from Lua to a DBMS (MySQL)
* [luasql-sqlite3]: LuaSQL is a simple interface from Lua to a DBMS (sqlite3)
* [redis-lua]: A Lua client library for the redis key value storage system
* [underscore.lua]: Underscore.lua is a Lua library that provides a set of utility functions for dealing with iterators, arrays, tables, and functions.

```shell
luarocks --local install lua-iconv
luarocks --local install lua-cjson
luarocks --local install lua-llthreads
luarocks --local install luafilesystem
luarocks --local install luaposix
luarocks --local install luasql-mysql MYSQL_INCDIR=/usr/include/mysql MYSQL_LIBDIR=/usr/lib64/mysql
luarocks --local install luasql-sqlite3
luarocks --local install redis-lua
luarocks --local install underscore.lua --from=http://marcusirven.s3.amazonaws.com/rocks/
```

Copyright and License
---------------------
Copyright 2012 Ivan Ribeiro Rocha

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[Apache]: http://httpd.apache.org/dev/devnotes.html
[OpenResty]: http://openresty.org/
[LuaJIT]: http://luajit.org/
[iconv]: http://luaforge.net/projects/lua-iconv/
[lua-cjson]: http://www.kyne.com.au/~mark/software/lua-cjson.php
[lua-llthreads]: http://github.com/Neopallium/lua-llthreads
[lua-zmq]: https://github.com/Neopallium/lua-zmq
[luaposix]: https://github.com/luaposix/luaposix
[luarocks]: http://luarocks.org/en
[luasql-mysql]: http://www.keplerproject.org/luasql/
[luasql-sqlite3]: http://www.keplerproject.org/luasql/
[redis-lua]: http://github.com/nrk/redis-lua
[underscore.lua]: http://mirven.github.io/underscore.lua/
