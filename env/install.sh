#!/bin/bash
echo "uninstalling all lua environment..."
cd
rm -rf ~/.luarocks ~/.cache/luarocks
sudo rm -rf /usr/sbin/nginx /usr/local/openresty* /usr/local/bin/lua* /usr/local/bin/resty /usr/local/bin/squish /usr/local/bin/sockproc /etc/ld.so.conf.d/drizzle7.conf /etc/ld.so.conf.d/luajit.conf /usr/local/lib/libdrizzle.*
sudo ldconfig
sudo rm -rf /opt/lua
sudo mkdir -p /opt/lua
sudo chown irocha: /opt/lua
echo "installing dependencies..."
sudo yum install -y luarocks lua-devel pandoc readline-devel pcre-devel openssl-devel \
                 sqlite-devel mysql-devel \
                 zeromq3 zeromq3-devel GeoIP-devel \
                 apr-devel apr-util-devel libapreq2 libapreq2-devel
sudo yum install -y perl-CPAN perl-Text-Diff perl-Test-LongString \
                 perl-List-MoreUtils perl-Test-Base \
                 perl-IO-Socket-SSL perl-Time-HiRes \
                 perl-Protocol-WebSocket
echo "installing openresty..."
cd /opt/lua
wget http://agentzh.org/misc/nginx/drizzle7-2011.07.21.tar.gz
tar xfva drizzle7-2011.07.21.tar.gz
cd drizzle7-2011.07.21/
./configure --without-server
make libdrizzle-1.0
sudo make install-libdrizzle-1.0
sudo cp ~/lua/configs/drizzle7.conf /etc/ld.so.conf.d/
sudo ldconfig && ldconfig -p |grep drizzle
cd ..
rm -rf drizzle7-2011.07.21*
wget http://openresty.org/download/ngx_openresty-1.9.3.2.tar.gz
tar xfva ngx_openresty-1.9.3.2.tar.gz
cd ngx_openresty-1.9.3.2
./configure --prefix=/opt/lua/openresty \
            --with-http_gunzip_module \
            --with-luajit \
            --with-http_geoip_module \
            --with-http_realip_module \
            --with-http_iconv_module \
            --with-http_stub_status_module \
            --with-http_ssl_module \
            --with-http_realip_module \
            --with-http_spdy_module \
            --with-http_drizzle_module \
            --with-md5-asm \
            --with-sha1-asm \
            --with-file-aio \
            --with-stream \
            --with-stream_ssl_module \
            --without-http_fastcgi_module \
            --without-http_uwsgi_module \
            --without-http_scgi_module \
            --with-debug
make -j4
make install
echo "creating symlinks..."
cd /usr/sbin
sudo ln -s /opt/lua/openresty/nginx/sbin/nginx
cd /usr/local/bin
sudo ln -s /opt/lua/openresty/luajit/bin/luajit-2.1.0-beta1 luajit
sudo ln -s /opt/lua/openresty/bin/resty
cd /usr/local
sudo ln -s /opt/lua/openresty openresty
sudo ln -s /opt/lua/openresty openresty-debug
ls -alF /usr/local/bin;echo
echo "updating libraries..."
sudo cp ~/lua/configs/luajit.conf /etc/ld.so.conf.d/
sudo ldconfig && ldconfig -p | grep luaj
cd /opt/lua
mkdir -p ~/.luarocks
if [ ! -d "luarocks" ]; then ln -s ~/.luarocks luarocks; fi
git clone https://github.com/openresty/openresty.org.git
git clone https://github.com/openresty/test-nginx.git
cd test-nginx
perl Makefile.PL
make
sudo make install
cd ..
git clone https://github.com/openresty/nginx-tutorials.git
git clone git@github.com:irr/nginx-systemtap-toolkit.git
cd nginx-systemtap-toolkit
git remote add upstream https://github.com/openresty/nginx-systemtap-toolkit.git
git fetch upstream && git merge upstream/master && git push
mkdir -p /opt/lua/docs
mkdir -p /opt/lua/modules/nginx
cd /opt/lua/modules/nginx/
git clone https://github.com/openresty/headers-more-nginx-module.git
git clone https://github.com/openresty/set-misc-nginx-module.git
git clone https://github.com/calio/iconv-nginx-module.git
git clone https://github.com/openresty/lua-nginx-module.git
git clone https://github.com/openresty/lua-resty-dns.git
git clone https://github.com/pintsized/lua-resty-http.git
git clone https://github.com/openresty/lua-resty-lock.git
git clone https://github.com/openresty/lua-resty-memcached.git
git clone https://github.com/openresty/lua-resty-mysql.git
git clone https://github.com/openresty/lua-resty-redis.git
git clone https://github.com/openresty/lua-resty-string.git
git clone https://github.com/openresty/lua-resty-upload.git
git clone https://github.com/openresty/lua-resty-upstream-healthcheck.git
git clone https://github.com/openresty/lua-resty-websocket.git
git clone https://github.com/hamishforbes/lua-resty-upstream.git
git clone https://github.com/openresty/lua-resty-lrucache.git
git clone https://github.com/bungle/lua-resty-template.git
git clone https://github.com/openresty/lua-resty-limit-traffic.git
git clone https://github.com/jbochi/lua-resty-cassandra.git
mkdir -p /opt/lua/modules/forked
cd /opt/lua/modules/forked/
git clone git@github.com:irr/awesome-lua.git
cd awesome-lua
git remote add upstream https://github.com/LewisJEllis/awesome-lua.git
git fetch upstream && git merge upstream/master && git push
cd ..
git clone git@github.com:irr/router.lua.git
cd router.lua
git remote add upstream https://github.com/APItools/router.lua.git
git fetch upstream && git merge upstream/master && git push
cd ..
git clone git@github.com:irr/lua-resty-shell.git
cd lua-resty-shell
git remote add upstream https://github.com/juce/lua-resty-shell.git
git fetch upstream && git merge upstream/master && git push
cd ..
git clone git@github.com:irr/lua-pycrypto-aes.git
cd lua-pycrypto-aes
git remote add upstream https://github.com/siddontang/lua-pycrypto-aes.git
git fetch upstream && git merge upstream/master && git push
cd ..
git clone git@github.com:irr/luajit.io.git
cd luajit.io
git remote add upstream https://github.com/kingluo/luajit.io.git
git fetch upstream && git merge upstream/master && git push
cd ..
git clone git@github.com:irr/wrk.git
cd wrk
git remote add upstream https://github.com/wg/wrk.git
git fetch upstream && git merge upstream/master && git push
make
sudo mv wrk /usr/local/bin
make clean
cd ..
git clone git@github.com:irr/sockproc.git
cd sockproc
git remote add upstream https://github.com/juce/sockproc.git
git fetch upstream && git merge upstream/master && git push
make
sudo mv sockproc /usr/local/bin/
sudo chown root: /usr/local/bin/sockproc
make clean
cd ..
git clone git@github.com:irr/luaxml.git
cd luaxml
git remote add upstream https://github.com/kidd/luaxml.git
git fetch upstream && git merge upstream/master && git push
cd /opt/lua
git clone http://luajit.org/git/luajit-2.0.git
cd luajit-2.0
git checkout v2.1
cd ..
git clone git@github.com:irr/plc.git
cd plc
git remote add upstream https://github.com/philanc/plc.git
git fetch upstream && git merge upstream/master && git push
cd ..
git clone git@github.com:irr/underscore.lua.git
cd underscore.lua
git remote add upstream https://github.com/mirven/underscore.lua.git
git fetch upstream && git merge upstream/master && git push
cd ..
git clone git@github.com:irr/lua-bit-numberlua.git
cd lua-bit-numberlua
git remote add upstream https://github.com/davidm/lua-bit-numberlua.git
git fetch upstream && git merge upstream/master && git push
cd ..
git clone git@github.com:irr/luajit-examples.git
cd luajit-examples
git remote add upstream https://github.com/hnakamur/luajit-examples.git
git fetch upstream && git merge upstream/master && git push
cd ..
git clone git@github.com:irr/lua-lru.git
cd lua-lru
git remote add upstream https://github.com/starius/lua-lru.git
git fetch upstream && git merge upstream/master && git push
cd ..
git clone git@github.com:irr/computer_science_in_lua.git
cd computer_science_in_lua
git remote add upstream https://github.com/EvandroLG/computer_science_in_lua.git
git fetch upstream && git merge upstream/master && git push
cd ~/git
ln -s /opt/lua/modules/nginx/headers-more-nginx-module
ln -s /opt/lua/modules/nginx/set-misc-nginx-module
ln -s /opt/lua/modules/nginx/iconv-nginx-module
ln -s /opt/lua/modules/nginx/lua-nginx-module
ln -s /opt/lua/modules/nginx/lua-resty-dns
ln -s /opt/lua/modules/nginx/lua-resty-http
ln -s /opt/lua/modules/nginx/lua-resty-lock
ln -s /opt/lua/modules/nginx/lua-resty-memcached
ln -s /opt/lua/modules/nginx/lua-resty-mysql
ln -s /opt/lua/modules/nginx/lua-resty-redis
ln -s /opt/lua/modules/nginx/lua-resty-string
ln -s /opt/lua/modules/nginx/lua-resty-upload
ln -s /opt/lua/modules/nginx/lua-resty-upstream
ln -s /opt/lua/modules/nginx/lua-resty-upstream-healthcheck
ln -s /opt/lua/modules/nginx/lua-resty-websocket
ln -s /opt/lua/modules/nginx/lua-resty-lrucache
ln -s /opt/lua/modules/nginx/lua-resty-limit-traffic
ln -s /opt/lua/modules/nginx/lua-resty-cassandra
ln -s /opt/lua/openresty.org
ln -s /opt/lua/nginx-tutorials
ln -s /opt/lua/test-nginx
cd ~/gitf
ln -s /opt/lua/nginx-systemtap-toolkit
ln -s /opt/lua/modules/forked/awesome-lua
ln -s /opt/lua/modules/forked/lua-resty-shell
ln -s /opt/lua/modules/forked/lua-pycrypto-aes
ln -s /opt/lua/modules/forked/luajit.io
ln -s /opt/lua/modules/forked/wrk
ln -s /opt/lua/modules/forked/sockproc
ln -s /opt/lua/modules/forked/router.lua
ln -s /opt/lua/modules/forked/luaxml
ln -s /opt/lua/modules/forked/lua-lru
ln -s /opt/lua/modules/forked/computer_science_in_lua
ln -s /opt/lua/underscore.lua
ln -s /opt/lua/plc
ln -s /opt/lua/luajit-examples
ln -s /opt/lua/lua-bit-numberlua
cd
echo "installing squish..."
cd /opt/lua
tar xfva ~/lua/squish/package/squish-0.2.0.tar.gz
cd squish-0.2.0
make
sudo make install
cd
echo "generating documentation..."
sh lua/env/makedocs.sh
#echo "luarocks..."
# wget http://luarocks.org/releases/luarocks-2.2.1.tar.gz
# tar zxpf luarocks-2.2.1.tar.gz
# cd luarocks-2.2.1
# ./configure; sudo make bootstrap
# sudo luarocks install luasocket
# lua
luarocks --local install lpeg
luarocks --local install luabitop
luarocks --local install lua-apr
luarocks --local install lua-cjson
luarocks --local install lua-iconv
luarocks --local install lua-llthreads2
luarocks --local install luacrypto
luarocks --local install lualogging
luarocks --local install luaposix
luarocks --local install luasec OPENSSL_LIBDIR=/usr/lib64/
luarocks --local install luasql-mysql \
                         MYSQL_INCDIR=/usr/include/mysql \
                         MYSQL_LIBDIR=/usr/lib64/mysql
luarocks --local install luasql-sqlite3
luarocks --local install lzmq
luarocks --local install redis-lua
luarocks --local install stdlib
luarocks --local install underscore.lua \
                         --from=http://github.com/irr/underscore.lua/raw/master/rocks
echo "setup ok."
cd

