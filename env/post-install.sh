#!/bin/bash
cd /usr/sbin
sudo ln -s /opt/lua/openresty/nginx/sbin/nginx
cd /usr/local/bin
sudo ln -s /opt/lua/openresty/luajit/bin/luajit-2.1.0-alpha luajit
sudo ln -s /home/irocha/lua/openresty/luangx/luangx.lua luangx

cd /usr/local
sudo ln -s /opt/lua/openresty openresty
sudo ln -s /opt/lua/openresty openresty-debug

ls -alF /usr/local/bin;echo
