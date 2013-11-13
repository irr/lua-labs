#!/bin/bash
pandoc -S -o lua-nginx-module.html ../lua-nginx-module/README.markdown 
pandoc -S -o lua-resty-memcached.html ../lua-resty-memcached/README.markdown 
pandoc -S -o lua-resty-mysql.html ../lua-resty-mysql/README.markdown 
pandoc -S -o lua-resty-redis.html ../lua-resty-redis/README.markdown 
pandoc -S -o lua-resty-string.html ../lua-resty-string/README.markdown 
pandoc -S -o lua-resty-upload.html ../lua-resty-upload/README.markdown 
