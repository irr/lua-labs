#!/bin/bash
pandoc -S -o /opt/lua/docs/lua-nginx-module.html /opt/lua/lua-nginx-module/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-memcached.html /opt/lua/lua-resty-memcached/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-mysql.html /opt/lua/lua-resty-mysql/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-redis.html /opt/lua/lua-resty-redis/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-string.html /opt/lua/lua-resty-string/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-upload.html /opt/lua/lua-resty-upload/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-dns.html /opt/lua/lua-resty-dns/README.markdown 
