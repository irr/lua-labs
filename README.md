lua-labs
-----------

**lua-labs**  is a set of sample codes whose main purpose is to experiment and test *Lua* and *[OpenResty]/[Apache]*

```shell
yum install readline-devel pcre-devel openssl-devel libdrizzle-devel
tar xfva ngx_openresty-1.2.4.14.tar.gz
cd ngx_openresty-1.2.4.14
./configure --prefix=/data/Lua/openresty --with-luajit --with-http_drizzle_module
make install
```

```shell
apt-get install libreadline-dev libpcre3-dev libssl-dev libdrizzle-dev
tar xfva ngx_openresty-1.2.4.14.tar.gz
cd ngx_openresty-1.2.4.14
./configure --prefix=/data/Lua/openresty --with-luajit --with-http_drizzle_module --with-libdrizzle=/usr
make -j4 
make install
```

Dependencies
-----------

* [OpenResty]: A full-fledged web application server by bundling the standard Nginx core, lots of 3rd-party Nginx modules, as well as most of their external dependencies

* [luarocks]: Deployment and management system for Lua modules
* [json4lua]: A simple encoding of Javascript-like objects that is ideal for lightweight transmission of relatively weakly-typed data
* [redis-lua]: A Lua client library for the redis key value storage system
* [lua-llthreads]: Low-Level threads(pthreads or WIN32 threads) for Lua
* [luasql-sqlite3]: LuaSQL is a simple interface from Lua to a DBMS (sqlite3)
* [luasql-mysql]: LuaSQL is a simple interface from Lua to a DBMS (MySQL)
* [concurrentlua]: Concurrency oriented programming in Lua

```shell
luarocks --local install json4lua 
luarocks --local install redis-lua
luarocks --local install lua-llthreads
luarocks --local install luasql-sqlite3
luarocks --local install concurrentlua
luarocks --local install luasql-mysql MYSQL_INCDIR=/usr/include/mysql MYSQL_LIBDIR=/usr/lib64/mysql
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
[luarocks]: http://luarocks.org/en
[json4lua]: http://json.luaforge.net/
[lua-llthreads]: http://github.com/Neopallium/lua-llthreads
[redis-lua]: http://github.com/nrk/redis-lua
[luasql-sqlite3]: http://www.keplerproject.org/luasql/
[luasql-mysql]: http://www.keplerproject.org/luasql/
[concurrentlua]: https://github.com/lefcha/concurrentlua