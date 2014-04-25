#!/bin/bash
pandoc -S -o /opt/lua/docs/lua-nginx-module.html /opt/lua/modules/nginx/lua-nginx-module/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-dns.html /opt/lua/modules/nginx/lua-resty-dns/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-memcached.html /opt/lua/modules/nginx/lua-resty-memcached/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-mysql.html /opt/lua/modules/nginx/lua-resty-mysql/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-redis.html /opt/lua/modules/nginx/lua-resty-redis/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-shell.html /opt/lua/modules/forked/lua-resty-shell/README.md 
pandoc -S -o /opt/lua/docs/lua-resty-string.html /opt/lua/modules/nginx/lua-resty-string/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-upload.html /opt/lua/modules/nginx/lua-resty-upload/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-upstream.html /opt/lua/modules/nginx/lua-resty-upstream/README.md
