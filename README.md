lua-labs
-----------

**lua-labs**  is a set of sample codes whose main purpose is to experiment and test *Lua* and *[OpenResty]/[Apache]*

**CentOS 6.5/Ubuntu 14.04 LTS**
```shell
sudo yum install readline-devel pcre-devel openssl-devel sqlite-devel mysql-devel pcre-devel zeromq3 zeromq3-devel

sudo apt-get install libreadline6-dev libpcre3-dev libssl-dev libsqlite3-dev libmysqlclient-dev libpcre3-dev cpanminus libtext-diff-perl libtest-longstring-perl liblist-moreutils-perl libtest-base-perl libzmq3-dev

wget http://openresty.org/download/ngx_openresty-1.7.4.1.tar.gz
tar xfva ngx_openresty-1.7.4.1.tar.gz
cd ngx_openresty-1.7.4.1
./configure --prefix=/opt/lua/openresty --with-luajit --with-http_iconv_module --with-http_stub_status_module --with-debug
make install
```

```shell
cd /usr/sbin
sudo ln -s /opt/lua/openresty/nginx/sbin/nginx
cd /usr/local/bin
sudo ln -s /opt/lua/openresty/luajit/bin/luajit-2.1.0-alpha luajit

cd /usr/local
sudo ln -s /opt/lua/openresty openresty
sudo ln -s /opt/lua/openresty openresty-debug

cd /opt/lua
ln -s ~/.luarocks luarocks
```

```shell
sudo yum install perl-CPAN perl-Text-Diff perl-Test-LongString perl-List-MoreUtils perl-Test-Base perl-IO-Socket-SSL
# Test::Nginx
sudo make install
Installing /usr/local/share/perl5/Test/Nginx.pm
Installing /usr/local/share/perl5/Test/Nginx/Util.pm
Installing /usr/local/share/perl5/Test/Nginx/Socket.pm
Installing /usr/local/share/perl5/Test/Nginx/LWP.pm
Installing /usr/local/share/perl5/Test/Nginx/Socket/Lua.pm
Installing /usr/local/share/man/man3/Test::Nginx.3pm
Installing /usr/local/share/man/man3/Test::Nginx::Socket.3pm
Installing /usr/local/share/man/man3/Test::Nginx::Socket::Lua.3pm
Installing /usr/local/share/man/man3/Test::Nginx::LWP.3pm
Appending installation info to /usr/lib64/perl5/perllocal.pod
```

* [OpenResty]: A full-fledged web application server by bundling the standard Nginx core, lots of 3rd-party Nginx modules, as well as most of their external dependencies
* [luarocks]: Deployment and management system for Lua modules
* [lua-cjson]: Lua CJSON provides JSON support for Lua
* [lua-iconv]: Lua binding to the POSIX 'iconv' library
* [lua-llthreads2]: Low-Level threads(pthreads or WIN32 threads) for Lua (`llthreads` library rewritten without `LuaNativeObjects` code generator)
* [luacrypto]: LuaCrypto is a Lua frontend to the OpenSSL cryptographic library
* [luafilesystem]: Lua library developed to complement the set of functions related to file systems offered by the standard Lua distribution 
* [lualogging]: LuaLogging provides a simple API to use logging features in Lua
* [luasec]: LuaSec is a binding for OpenSSL library to provide TLS/SSL communication
* [luasql-mysql]: LuaSQL is a simple interface from Lua to a DBMS (MySQL)
* [luasql-sqlite3]: LuaSQL is a simple interface from Lua to a DBMS (sqlite3)
* [lzmq]: Lua binding to ZeroMQ
* [redis-lua]: A Lua client library for the redis key value storage system
* [underscore.lua]: A Lua library that provides a set of utility functions for dealing with iterators, arrays, tables, and functions

```shell
luarocks --local install lua-cjson
luarocks --local install lua-iconv
luarocks --local install lua-llthreads2
luarocks --local install luacrypto
luarocks --local install luafilesystem
luarocks --local install lualogging

luarocks --local install luasec OPENSSL_LIBDIR=/usr/lib64/
luarocks --local install luasec OPENSSL_LIBDIR=/usr/lib/i386-linux-gnu

luarocks --local install luasql-mysql MYSQL_INCDIR=/usr/include/mysql MYSQL_LIBDIR=/usr/lib64/mysql
luarocks --local install luasql-mysql MYSQL_INCDIR=/usr/include/mysql MYSQL_LIBDIR=/usr/lib/i386-linux-gnu

luarocks --local install luasql-sqlite3
luarocks --local install lzmq
luarocks --local install redis-lua
luarocks --local install underscore.lua --from=http://github.com/irr/underscore.lua/raw/master/rocks
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
[luafilesystem]: https://github.com/keplerproject/luafilesystem
[lualogging]: http://www.keplerproject.org/lualogging/
[luarocks]: http://luarocks.org/entcp-ngx-1.4.3.6
[luasec]: https://github.com/brunoos/luasec
[luasql-mysql]: http://www.keplerproject.org/luasql/
[luasql-sqlite3]: http://www.keplerproject.org/luasql/
[lzmq]: https://github.com/zeromq/lzmq
[redis-lua]: http://github.com/nrk/redis-lua
[underscore.lua]: https://github.com/irr/underscore.lua
