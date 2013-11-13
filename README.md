lua-labs
-----------

**lua-labs**  is a set of sample codes whose main purpose is to experiment and test *Lua* and *[OpenResty]/[Apache]*

**CentOS 6.4**
```shell
yum install readline-devel pcre-devel openssl-devel
tar xfva ngx_openresty-1.4.3.1.tar.gz
cd ngx_openresty-1.4.3.1
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
cd /usr/sbin
ln -s /opt/openresty/nginx/sbin/nginx
cd /usr/local/bin
ln -s /opt/openresty/luajit/bin/luajit

cd /usr/local
ln -s /opt/openresty openresty
ln -s /opt/openresty openresty-debug

cd /opt/lua
ln -s ~/.luarocks luarocks
```

**FreeBSD**
```shell
cd /usr/ports/devel/gmake
make install clean
cd /usr/ports/security/openssl
make install clean
cd /usr/ports/devel/pcre
make install clean

or

pkg_add -r -v gmake
pkg_add -r -v pcre
pkg_add -r -v openssl

# ... install openresty ...
```

```shell
cd /opt/openresty/luajit/bin/
ln -s luajit lua
```

```shell
tar xfvz luarocks-2.1.1.tar.gz
cd luarocks-2.1.1
./configure --with-lua=/opt/openresty/luajit --with-lua-include=/opt/openresty/luajit/include/luajit-2.0 --with-lua-lib=/opt/openresty/luajit/lib
gmake build
gmake install
```

```shell
luarocks --local install luasql-mysql MYSQL_INCDIR=/usr/local/include/mysql MYSQL_LIBDIR=/usr/local/lib/mysql
```

Dependencies
-----------

```shell
apt-get install libzmq-dev libsqlite3-dev libmysqlclient-dev libpcre3-dev
yum install czmq-devel sqlite-devel mysql-devel pcre-devel
```

Libraries
-----------

```shell
yum install zeromq-devel sqlite-devel mysql-devel
```

* [OpenResty]: A full-fledged web application server by bundling the standard Nginx core, lots of 3rd-party Nginx modules, as well as most of their external dependencies

* [lua-cjson]: Lua CJSON provides JSON support for Lua
* [lua-iconv]: Lua binding to the POSIX 'iconv' library
* [lua-llthreads]: Low-Level threads(pthreads or WIN32 threads) for Lua
* [lua-zmq]: Lua bindings to zeromq2
* [luaposix]: Lua bindings for POSIX APIs
* [luafilesystem]: Lua library developed to complement the set of functions related to file systems offered by the standard Lua distribution 
* [luarocks]: Deployment and management system for Lua modules
* [luasql-mysql]: LuaSQL is a simple interface from Lua to a DBMS (MySQL)
* [luasql-sqlite3]: LuaSQL is a simple interface from Lua to a DBMS (sqlite3)
* [redis-lua]: A Lua client library for the redis key value storage system
* [underscore.lua]: Underscore.lua is a Lua library that provides a set of utility functions for dealing with iterators, arrays, tables, and functions.

```shell
luarocks --local install lua-iconv
luarocks --local install lua-cjson
luarocks --local install lua-llthreads
luarocks --local install lua-zmq-threads ZEROMQ_INCDIR=/usr/include ZEROMQ_LIBDIR=/usr/lib64
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
[lua-iconv]: http://luaforge.net/projects/lua-iconv/
[lua-cjson]: http://www.kyne.com.au/~mark/software/lua-cjson.php
[lua-llthreads]: http://github.com/Neopallium/lua-llthreads
[lua-zmq]: https://github.com/Neopallium/lua-zmq
[luaposix]: https://github.com/luaposix/luaposix
[luafilesystem]: https://github.com/keplerproject/luafilesystem
[luarocks]: http://luarocks.org/en
[luasql-mysql]: http://www.keplerproject.org/luasql/
[luasql-sqlite3]: http://www.keplerproject.org/luasql/
[redis-lua]: http://github.com/nrk/redis-lua
[underscore.lua]: http://mirven.github.io/underscore.lua/
