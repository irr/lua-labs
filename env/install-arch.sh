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
wget http://openresty.org/download/ngx_openresty-1.7.7.2.tar.gz
tar xfva ngx_openresty-1.7.7.2.tar.gz
cd ngx_openresty-1.7.7.2
patch -p1 < ../nginx_tcp_proxy_module/tcp-ngx-1.7.7.2.patch
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
git clone https://github.com/openresty/openresty.org.git
git clone https://github.com/openresty/nginx-tutorials.git
git clone http://luajit.org/git/luajit-2.0.git
cd luajit-2.0
git checkout v2.1
cd ..
git clone git@github.com:irr/luajit-examples.git
cd luajit-examples
git remote add upstream https://github.com/hnakamur/luajit-examples.git
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
git clone https://github.com/openresty/lua-resty-memcached.git
git clone https://github.com/openresty/lua-resty-mysql.git
git clone https://github.com/openresty/lua-resty-redis.git
git clone https://github.com/openresty/lua-resty-string.git
git clone https://github.com/openresty/lua-resty-upload.git
git clone https://github.com/openresty/lua-resty-upstream-healthcheck.git
git clone https://github.com/hamishforbes/lua-resty-upstream.git
git clone https://github.com/openresty/lua-resty-lrucache.git
git clone https://github.com/bungle/lua-resty-template.git
mkdir -p /opt/lua/modules/forked
cd /opt/lua/modules/forked/
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
git clone git@github.com:irr/sockproc.git
cd sockproc
git remote add upstream https://github.com/juce/sockproc.git
git fetch upstream && git merge upstream/master && git push
make
sudo mv sockproc /usr/local/bin/
make clean
cd ..
cd ~/git
ln -s /opt/lua/modules/nginx/headers-more-nginx-module
ln -s /opt/lua/modules/nginx/set-misc-nginx-module
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
ln -s /opt/lua/modules/nginx/lua-resty-upstream-healthcheck
ln -s /opt/lua/modules/nginx/lua-resty-lrucache
ln -s /opt/lua/openresty.org
ln -s /opt/lua/nginx-tutorials
ln -s /opt/lua/test-nginx
cd ~/gitf
ln -s /opt/lua/modules/forked/lua-resty-shell
ln -s /opt/lua/modules/forked/lua-pycrypto-aes
ln -s /opt/lua/modules/forked/sockproc
ln -s /opt/lua/nginx_tcp_proxy_module
ln -s /opt/lua/luajit-examples
cd

