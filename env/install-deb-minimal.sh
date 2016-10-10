#!/bin/bash
echo "uninstalling all lua environment..."
cd
rm -rf ~/.luarocks ~/.cache/luarocks
sudo rm -rf /usr/sbin/nginx /usr/local/openresty* /usr/local/bin/lua* /usr/local/bin/resty /usr/local/bin/squish /usr/local/bin/sockproc /etc/ld.so.conf.d/drizzle7.conf /etc/ld.so.conf.d/luajit.conf
sudo ldconfig
sudo rm -rf /opt/lua
sudo mkdir -p /opt/lua
sudo chown irocha: /opt/lua
echo "installing dependencies..."
sudo apt-get install lua5.1 lua5.1-doc luarocks pandoc rlwrap libreadline6-dev libpcre3-dev libssl-dev \
                     libsqlite3-dev libmysqlclient-dev libzmq3-dev libboost-all-dev \
                     geoip-bin geoip-database libgeoip-dev \
                     libapr1 libaprutil1 libaprutil1-dev libaprutil1-dbd-sqlite3 \
                     libapreq2-3 libapr1-dev libapreq2-dev
sudo apt-get install c-cpp-reference scons-doc cpanminus libtext-diff-perl \
                     libtest-longstring-perl \
                     liblist-moreutils-perl \
                     libtest-base-perl \
                     liblwp-useragent-determined-perl
echo "installing openresty..."
cd /opt/lua
wget http://openresty.org/download/openresty-1.11.2.1.tar.gz
tar xfva openresty-1.11.2.1.tar.gz
cd openresty-1.11.2.1
./configure --prefix=/opt/lua/openresty \
            --with-http_gunzip_module \
            --with-luajit \
            --with-http_geoip_module \
            --with-http_realip_module \
            --with-http_iconv_module \
            --with-http_stub_status_module \
            --with-http_ssl_module \
            --with-http_realip_module \
            --with-http_v2_module \
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
sudo ln -s /opt/lua/openresty/luajit/bin/luajit-2.1.0-beta2 luajit
sudo ln -s /opt/lua/openresty/bin/openresty
sudo ln -s /opt/lua/openresty/bin/resty
sudo ln -s /opt/lua/openresty/bin/restydoc
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
git clone https://github.com/openresty/test-nginx.git
cd test-nginx
perl Makefile.PL
make
sudo make install
cd ..
rm -rf test-nginx
git clone git@github.com:irr/wrk.git
cd wrk
git remote add upstream https://github.com/wg/wrk.git
git fetch upstream && git merge upstream/master && git push
make
sudo mv wrk /usr/local/bin
make clean
cd ..
rm -rf wrk
git clone git@github.com:irr/sockproc.git
cd sockproc
git remote add upstream https://github.com/juce/sockproc.git
git fetch upstream && git merge upstream/master && git push
make
sudo mv sockproc /usr/local/bin/
sudo chown root: /usr/local/bin/sockproc
make clean
cd ..
rm -rf sockproc
cd /opt/lua
git clone http://luajit.org/git/luajit-2.0.git
cd luajit-2.0
git checkout v2.1.0-beta2
cd ..
git clone git@github.com:irr/underscore.lua.git
cd underscore.lua
git remote add upstream https://github.com/mirven/underscore.lua.git
git fetch upstream && git merge upstream/master && git push
cd ~/gitf
ln -s /opt/lua/underscore.lua
cd
echo "installing rocks..."
. ~/.bashrc
luarocks --local install lua-cjson
luarocks --local install underscore.lua \
                         --from=http://github.com/irr/underscore.lua/raw/master/rocks
echo "setup ok."
