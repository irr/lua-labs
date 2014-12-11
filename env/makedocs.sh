#!/bin/bash
pandoc -S -o /opt/lua/docs/headers-more-nginx-module.html /opt/lua/modules/nginx/headers-more-nginx-module/README.markdown
pandoc -S -o /opt/lua/docs/set-misc-nginx-module.html /opt/lua/modules/nginx/set-misc-nginx-module/README.markdown
pandoc -S -o /opt/lua/docs/lua-nginx-module.html /opt/lua/modules/nginx/lua-nginx-module/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-dns.html /opt/lua/modules/nginx/lua-resty-dns/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-memcached.html /opt/lua/modules/nginx/lua-resty-memcached/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-mysql.html /opt/lua/modules/nginx/lua-resty-mysql/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-redis.html /opt/lua/modules/nginx/lua-resty-redis/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-string.html /opt/lua/modules/nginx/lua-resty-string/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-upload.html /opt/lua/modules/nginx/lua-resty-upload/README.markdown 
pandoc -S -o /opt/lua/docs/lua-resty-http.html /opt/lua/modules/nginx/lua-resty-http/README.md
pandoc -S -o /opt/lua/docs/lua-resty-upstream.html /opt/lua/modules/nginx/lua-resty-upstream/README.md
pandoc -S -o /opt/lua/docs/lua-resty-upstream-healthcheck.html /opt/lua/modules/nginx/lua-resty-upstream-healthcheck/README.markdown
pandoc -S -o /opt/lua/docs/lua-resty-lrucache.html /opt/lua/modules/nginx/lua-resty-lrucache/README.markdown
pandoc -S -o /opt/lua/docs/lua-pycrypto-aes.html /opt/lua/modules/forked/lua-pycrypto-aes/readme.md
pandoc -S -o /opt/lua/docs/lua-resty-template.html /opt/lua/modules/nginx/lua-resty-template/README.md
pandoc -S -o /opt/lua/docs/lua-resty-shell.html /opt/lua/modules/forked/lua-resty-shell/README.md 
pandoc -S -o /opt/lua/docs/sockproc.html /opt/lua/modules/forked/sockproc/README.md
pandoc -S -o /opt/lua/docs/test-nginx.html /opt/lua/test-nginx/README.md || rm -rf /opt/lua/docs/test-nginx.html
