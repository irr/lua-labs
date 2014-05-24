#!/bin/bash
mkdir -p /opt/lua
sudo chown -R irocha: /opt/lua
git clone https://github.com/openresty/openresty.org.git
mkdir -p /opt/lua/docs
mkdir -p /opt/lua/modules/nginx
cd /opt/lua/modules/nginx/
git clone https://github.com/openresty/array-var-nginx-module.git
git clone https://github.com/openresty/headers-more-nginx-module.git
git clone https://github.com/calio/iconv-nginx-module.git
git clone https://github.com/openresty/lua-nginx-module.git
git clone https://github.com/openresty/lua-resty-dns.git
git clone https://github.com/pintsized/lua-resty-http.git
git clone https://github.com/openresty/lua-resty-memcached.git
git clone https://github.com/openresty/lua-resty-mysql.git
git clone https://github.com/openresty/lua-resty-redis.git
git clone https://github.com/openresty/lua-resty-string.git
git clone https://github.com/openresty/lua-resty-upload.git
git clone https://github.com/hamishforbes/lua-resty-upstream.git
mkdir -p /opt/lua/modules/forked
cd /opt/lua/modules/forked/
git clone git@github.com:irr/lua-resty-shell.git
cd lua-resty-shell
git remote add upstream https://github.com/juce/lua-resty-shell.git
cd ..
git clone git@github.com:irr/lua-pycrypto-aes.git
cd lua-pycrypto-aes
git remote add upstream https://github.com/siddontang/lua-pycrypto-aes.git
cd ..
git clone git@github.com:irr/sockproc.git
cd sockproc
git remote add upstream https://github.com/juce/sockproc.git
cd ..
git clone git@github.com:irr/nginx_tcp_proxy_module.git
cd nginx_tcp_proxy_module
git remote add upstream https://github.com/yaoweibin/nginx_tcp_proxy_module.git
cd /opt/lua
git clone git@github.com:irr/underscore.lua.git
cd underscore.lua
git remote add upstream https://github.com/mirven/underscore.lua.git
cd ..
git clone git@github.com:irr/openresty-docker.git
cd openresty-docker
git remote add upstream https://github.com/torhve/openresty-docker.git
cd ..
cd ~/git
ln -s /opt/lua/modules/nginx/array-var-nginx-module
ln -s /opt/lua/modules/nginx/headers-more-nginx-module
ln -s /opt/lua/modules/nginx/iconv-nginx-module
ln -s /opt/lua/modules/nginx/lua-nginx-module
ln -s /opt/lua/modules/nginx/lua-resty-dns
ln -s /opt/lua/modules/nginx/lua-resty-http
ln -s /opt/lua/modules/nginx/lua-resty-memcached
ln -s /opt/lua/modules/nginx/lua-resty-mysql
ln -s /opt/lua/modules/nginx/lua-resty-redis
ln -s /opt/lua/modules/nginx/lua-resty-string
ln -s /opt/lua/modules/nginx/lua-resty-upload
ln -s /opt/lua/modules/nginx/lua-resty-upstream
cd ~/gitf
ln -s /opt/lua/modules/forked/lua-resty-shell
ln -s /opt/lua/modules/forked/lua-pycrypto-aes
ln -s /opt/lua/modules/forked/sockproc
ln -s /opt/lua/modules/forked/nginx_tcp_proxy_module
ln -s /opt/lua/underscore.lua
ln -s /opt/lua/openresty-docker
cd