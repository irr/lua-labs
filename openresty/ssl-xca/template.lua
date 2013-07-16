#!/usr/bin/env luajit

require("luarocks.loader")

local _ = require("underscore")

local port    = 8443
local certdir = '/home/irocha/lua/openresty/ssl-xca/certs'
local codedir = '/home/irocha/lua/openresty/ssl-xca'
local confdir = '/home/irocha/lua/openresty/ssl-xca/includes'
local basedir = '/opt/openresty/nginx'

local base = [[
worker_processes    4;
worker_cpu_affinity 0001 0010 0100 1000;

error_log $basedir/logs/error.log info;

events {
    worker_connections 1024;
}

http {

    ssl_ciphers HIGH:!kEDH:@STRENGTH;
    ssl_prefer_server_ciphers on;
    ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_session_cache shared:SSL:10m;

    include $confdir/*.conf;
}

]]

local upstream = [[
upstream $domain {
$servers}

]]

local fallback = [[
server {
    listen $port default ssl;
    server_name _;

    ssl on;  
    ssl_certificate $certdir/multiple-domains.crt;  
    ssl_certificate_key $certdir/multiple-domains.pem;  
    
    ssl_ciphers RC4:!MD5;

    location / {
        content_by_lua_file '$codedir/ssl-router.lua';
    }
}

]]

local server = [[
server {
    listen $port ssl;
    server_name $domain;

    ssl on;  
    ssl_certificate $certdir/$domain.crt;
    ssl_certificate_key $certdir/$domain.pem;        

    location / {
        proxy_redirect      off;
        proxy_set_header    Host $host;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto https;
        proxy_pass          http://$domain;
    }
}

]]

function render_config (values)
    local ngxconf, incconf = "$codedir/nginx.conf", "$confdir/default.conf"
    local config = { [ngxconf:gsub('%$(%w+)', values)] = 
                        base:gsub('%$(%w+)', values),
                     [incconf:gsub('%$(%w+)', values)] =  
                        fallback:gsub('%$(%w+)', values) }
    return _.reduce(values.domains, config, 
        function (config, domain)
            values.domain = domain
            values.servers = _.reduce(values[domain], '', function (servers, server) 
                return string.format('%s    server %s;\n', servers, server)
            end)
            local dconf = "$confdir/" .. domain .. ".conf" 
            config[dconf:gsub('%$(%w+)', values)] = upstream:gsub('%$(%w+)', values) .. server:gsub('%$(%w+)', values)
            return config
        end)
end

values = { ['myirrlab.org'] = { 'www.uol.com.br', 'www.uol.com.br' },
           ['myirrlab.net'] = { 'www.google.com.br', 'www.google.com.br' },
           domains = { 'myirrlab.org', 'myirrlab.net' },
           basedir = basedir, 
           certdir = certdir, 
           codedir = codedir,
           confdir = confdir,
           port = port }

local config = render_config(values)

_.each(_.keys(config), function (name)
        file = io.open(name, 'w+')
        file:write(config[name])
        file:close()
    end)

