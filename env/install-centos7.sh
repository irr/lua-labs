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
sudo yum install -y lua-devel pandoc readline-devel pcre-devel openssl-devel \
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
make -j4 libdrizzle-1.0
sudo make install-libdrizzle-1.0
sudo cp /media/sf_irocha/lua/configs/drizzle7.conf /etc/ld.so.conf.d/
sudo ldconfig && ldconfig -p |grep drizzle
cd ..
rm -rf drizzle7-2011.07.21*
wget http://openresty.org/download/ngx_openresty-1.9.3.2rc2.tar.gz
tar xfva ngx_openresty-1.9.3.2rc2.tar.gz
cd ngx_openresty-1.9.3.2rc2
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
sudo cp /media/sf_irocha/lua/configs/luajit.conf /etc/ld.so.conf.d/
sudo ldconfig && ldconfig -p | grep luaj
cd /opt/lua
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
echo "setup ok."
cd

