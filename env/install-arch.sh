#!/bin/bash
echo "installing dependencies..."
sudo pacman -S pcre libmariadbclient cpanminus perl-text-diff perl-list-moreutils perl-lwp-protocol-https perl-test-base
echo "installing openresty..."
cd /opt/lua
git clone git@github.com:irr/nginx_tcp_proxy_module.git
cd nginx_tcp_proxy_module
git remote add upstream https://github.com/yaoweibin/nginx_tcp_proxy_module.git
git fetch upstream && git merge upstream/master && git push
cd ..
wget http://openresty.org/download/ngx_openresty-1.7.7.1.tar.gz
tar xfva ngx_openresty-1.7.7.1.tar.gz
cd ngx_openresty-1.7.7.1
patch -p1 < ../nginx_tcp_proxy_module/tcp-ngx-1.7.7.1.patch
./configure --prefix=/opt/lua/openresty \
            --with-luajit \
            --with-http_realip_module \
            --with-http_iconv_module \
            --with-http_stub_status_module \
            --with-debug --add-module=../nginx_tcp_proxy_module
make install
echo "creating symlinks..."
cd /usr/sbin
sudo ln -s /opt/lua/openresty/nginx/sbin/nginx
cd /usr/local/bin
sudo ln -s /opt/lua/openresty/luajit/bin/luajit-2.1.0-alpha luajit
sudo ln -s /home/irocha/lua/openresty/luangx/luangx.lua luangx
cd /usr/local
sudo ln -s /opt/lua/openresty openresty
sudo ln -s /opt/lua/openresty openresty-debug
ls -alF /usr/local/bin;echo
echo "updating libraries..."
sudo cp ~/lua/configs/luajit.conf /etc/ld.so.conf.d/
sudo ldconfig && ldconfig -p | grep luaj
cd /opt/lua
wget http://search.cpan.org/CPAN/authors/id/R/RG/RGARCIA/Test-LongString-0.17.tar.gz
tar xfva Test-LongString-0.17.tar.gz
cd Test-LongString-0.17
perl Makefile.PL
make
sudo make install
cd ..
rm -rf Test-LongString-0.17 Test-LongString-0.17.tar.gz
git clone https://github.com/openresty/test-nginx.git
cd test-nginx
perl Makefile.PL
make
sudo make install
cd ..
rm -rf test-nginx
git clone git@github.com:irr/sockproc.git
cd sockproc
git remote add upstream https://github.com/juce/sockproc.git
git fetch upstream && git merge upstream/master && git push
make
sudo mv sockproc /usr/local/bin/
cd ..
rm -rf sockproc
