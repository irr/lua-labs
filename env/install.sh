#!/bin/bash
cd &&
rm -rf .luarocks && 
luarocks --local install lua-cjson && 
luarocks --local install lua-iconv && 
luarocks --local install redis-lua && 
luarocks --local install luasql-mysql MYSQL_INCDIR=/usr/include/mysql MYSQL_LIBDIR=/usr/lib64/mysql &&
luarocks --local install lualogging &&
luarocks --local install luasec OPENSSL_LIBDIR=/usr/lib64/ &&
luarocks --local install luasql-sqlite3
luarocks --local list
