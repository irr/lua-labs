lua-labs
-----------

**lua-labs**  is a set of sample codes whose main purpose is to experiment and test *Lua* and *[OpenResty]/[Apache]*

* [OpenResty]: A fast and scalable web application platform by extending NGINX with Lua
* [luarocks]: Deployment and management system for Lua modules
* [lua-cjson]: Lua CJSON provides JSON support for Lua
* [lua-iconv]: Lua binding to the POSIX 'iconv' library
* [lua-llthreads2]: Low-Level threads(pthreads or WIN32 threads) for Lua
* [luacrypto]: LuaCrypto is a Lua frontend to the OpenSSL cryptographic library
* [lualogging]: LuaLogging provides a simple API to use logging features in Lua
* [luasec]: LuaSec is a binding for OpenSSL library to provide TLS/SSL communication
* [luasql-mysql]: LuaSQL is a simple interface from Lua to a DBMS (MySQL)
* [luasql-sqlite3]: LuaSQL is a simple interface from Lua to a DBMS (sqlite3)
* [lzmq]: Lua binding to ZeroMQ
* [redis-lua]: A Lua client library for the redis key value storage system
* [stdlib]: General Lua libraries
* [underscore.lua]: A utility library for Lua

```shell
luarocks --local install lua-cjson
luarocks --local install lua-iconv
luarocks --local install lua-llthreads2
luarocks --local install luacrypto
luarocks --local install lualogging

luarocks --local install luasec OPENSSL_LIBDIR=/usr/lib64/
luarocks --local install luasec OPENSSL_LIBDIR=/usr/lib/x86_64-linux-gnu 
luarocks --local install luasec OPENSSL_LIBDIR=/usr/lib/i386-linux-gnu

luarocks --local install luasql-mysql \
                         MYSQL_INCDIR=/usr/include/mysql \
                         MYSQL_LIBDIR=/usr/lib64/mysql
luarocks --local install luasql-mysql \
                         MYSQL_INCDIR=/usr/include/mysql \
                         MYSQL_LIBDIR=/usr/lib/x86_64-linux-gnu
luarocks --local install luasql-mysql \
                         MYSQL_INCDIR=/usr/include/mysql \
                         MYSQL_LIBDIR=/usr/lib/i386-linux-gnu

luarocks --local install luasql-sqlite3
luarocks --local install lzmq
luarocks --local install redis-lua

luarocks --local install stdlib

luarocks --local install underscore.lua \
                         --from=http://github.com/irr/underscore.lua/raw/master/rocks
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
[lua-cjson]: http://www.kyne.com.au/~mark/software/lua-cjson.php
[lua-iconv]: http://luaforge.net/projects/lua-iconv/
[lua-llthreads2]: https://github.com/moteus/lua-llthreads2
[luacrypto]: http://luacrypto.luaforge.net/manual.html
[lualogging]: http://www.keplerproject.org/lualogging/
[luarocks]: http://luarocks.org/entcp-ngx-1.4.3.6
[luasec]: http://github.com/brunoos/luasec
[luasql-mysql]: http://www.keplerproject.org/luasql/
[luasql-sqlite3]: http://www.keplerproject.org/luasql/
[lzmq]: http://github.com/zeromq/lzmq
[redis-lua]: http://github.com/nrk/redis-lua
[stdlib]: https://github.com/lua-stdlib/lua-stdlib
[underscore.lua]: http://github.com/irr/underscore.lua
